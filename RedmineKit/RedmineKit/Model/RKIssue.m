//
//  Issue.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKIssue.h"
#import "RKRedmine.h"
#import "JSON.h"
#import "RKIssueOptions.h"
#import "TFHpple.h"
#import "RKParseHelper.h"
#import "RKProject.h"
#import "RKValue.h"

@interface RKIssue ()
- (void)loadJournals;
@end

@implementation RKIssue

@synthesize status=_status;
@synthesize author=_author;
@synthesize doneRatio=_doneRatio;
@synthesize assignedTo=_assignedTo;
@synthesize fixedVersion=_fixedVersion;
@synthesize createdOn=_createdOn;
@synthesize subject=_subject;
@synthesize updatedOn=_updatedOn;
@synthesize spentHours=_spentHours;
@synthesize tracker=_tracker;
@synthesize index=_index;
@synthesize startDate=_startDate;
@synthesize dueDate=_dueDate;
@synthesize priority=_priority;
@synthesize project=_project;
@synthesize issueDescription=_issueDescription;
@synthesize journals=_journals;
//@synthesize activity=_activity;


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ #%@ (%@): %@, adicionado por %@", 
            self.tracker.name, self.index, self.status.name, self.subject, self.author.name];
}

- (NSMutableArray *)journals
{
    if (_journals == nil) {
        [self loadJournals];
    }
    
    return _journals;
}

- (void)loadJournals
{
    NSString *urlString         = [NSString stringWithFormat:@"%@/projects/%@/issues/%@.json?include=journals&key=%@", self.project.redmine.serverAddress, self.project.index, self.index, self.project.redmine.apiKey];
    NSURL *url                  = [NSURL URLWithString:urlString];
    NSError *error              = nil;
    NSString *responseString    = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"Loading journals from %@. Response: \n%@", urlString, responseString);
    _journals                   = [[NSMutableArray alloc] init];
    if (!error) {
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSDictionary *issueDict = [jsonDict objectForKey:@"issue"];
        NSDictionary *journalsDict  = [issueDict objectForKey:@"journals"];
        for (NSDictionary *journalDict in journalsDict) {
            RKJournal *aJournal = [[RKJournal alloc] init];
            aJournal.index      = [journalDict objectForKey:@"id"];
            aJournal.createdOn  = [RKParseHelper dateForString:[journalDict objectForKey:@"created_on"]];
            aJournal.user       = [RKParseHelper valueForDict:[journalDict objectForKey:@"user"]];
            aJournal.notes      = [journalDict objectForKey:@"notes"];
            aJournal.details    = [NSMutableArray array];
            for (NSDictionary *detailDict in [journalDict objectForKey:@"details"]) {
                RKJournalDetail *detail = [[RKJournalDetail alloc] init];
                detail.theNewValue  = [journalDict objectForKey:@"new_value"];
                detail.property     = [journalDict objectForKey:@"property"];
                detail.theOldValue  = [journalDict objectForKey:@"old_value"];
                detail.name         = [journalDict objectForKey:@"name"];
                [aJournal.details addObject:detail];
            }
            [_journals addObject:aJournal];
        }
    } else {
        NSLog(@"Error retrieving journals: %@", [error localizedDescription]);
    }
}

- (NSMutableArray *)refreshJournals
{
    _journals = nil;
    return [self journals];
}

- (RKIssueOptions *)updateOptions;
{
    RKIssueOptions *options = [[RKIssueOptions alloc] init];
    
    NSString *urlString     = [NSString stringWithFormat:@"%@/issues/%@?key=%@", self.project.redmine.serverAddress, self.index, self.project.redmine.apiKey];
    NSURL *url              = [NSURL URLWithString:urlString];
    NSData  *data           = [NSData dataWithContentsOfURL:url];
    TFHpple *doc            = [[TFHpple alloc] initWithHTMLData:data];
    
    options.trackers    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_tracker_id']/option"];
    options.statuses    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_status_id']/option"];
    options.priorities  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_priority_id']/option"];
    options.categories  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_category_id']/option"];
    options.versions    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_fixed_version_id']/option"];
    options.assignableUsers = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_assigned_to_id']/option"];
    options.activities  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='time_entry_activity_id']/option"];
    
    
    return options;
}

- (BOOL)postUpdateWithNotes:(NSString *)notes
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *issueDict = [self issueDictWithNotes:notes];
    [jsonDict setObject:issueDict forKey:@"issue"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"updating issue from project %@ and redmine %@", self.project, self.project.redmine);
    NSString *urlString = [NSString stringWithFormat:@"%@/issues/%@.json?key=%@", self.project.redmine.serverAddress, self.index, self.project.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSLog(@"[PUT] %@: \n%@", urlString, jsonString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSError *error      = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    if (error) {
        NSLog(@"%d: Error updating issue: %@\n%@", [response statusCode], [error localizedDescription], responseString);
        return NO;
    } else {
        NSLog(@"Issue %@ successfully updated. Response:\n%@", self.index, responseString);
        return YES;
    }
}

- (BOOL)postTimeEntry:(RKTimeEntry *)entry
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
    {
        if (entry.activity.index)   [entryDict setObject:entry.activity.index forKey:@"activity_id"];
        if (entry.issueIndex)       [entryDict setObject:entry.issueIndex forKey:@"issue_id"];
        if (entry.spentOn)          [entryDict setObject:[RKParseHelper shortDateStringFromDate:entry.spentOn] forKey:@"spent_on"];
        if (entry.hours)            [entryDict setObject:entry.hours forKey:@"hours"];
        if (entry.comments)         [entryDict setObject:entry.comments forKey:@"comments"];
    }
    [jsonDict setObject:entryDict forKey:@"time_entry"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/projects/%@/time_entries.json?key=%@", self.project.redmine.serverAddress, self.project.index, self.project.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSLog(@"[POST] %@: \n%@", urlString, jsonString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSError *error      = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    if (error) {
        NSLog(@"%d: Error posting time entry: %@\n%@", [response statusCode], [error localizedDescription], responseString);
        return NO;
    } else {
        NSLog(@"Time entry successfully posted. Response:\n%@", responseString);
        return YES;
    }
}

- (NSMutableDictionary *)issueDictWithNotes:(NSString *)notes
{
    NSMutableDictionary *issueDict = [NSMutableDictionary dictionary];
    if (notes != nil) [issueDict setObject:notes forKey:@"notes"];
    if (self.subject)      [issueDict setObject:self.subject forKey:@"subject"];
    if (self.status.index)       [issueDict setObject:self.status.index forKey:@"status_id"];
    if (self.assignedTo.index)   [issueDict setObject:self.assignedTo.index forKey:@"assigned_to_id"];
    if (self.doneRatio)    [issueDict setObject:self.doneRatio forKey:@"done_ratio"];
    if (self.dueDate)      [issueDict setObject:[RKParseHelper shortDateStringFromDate:self.dueDate] forKey:@"due_date"];
    if (self.startDate)    [issueDict setObject:[RKParseHelper shortDateStringFromDate:self.startDate] forKey:@"start_date"];
    if (self.spentHours)   [issueDict setObject:self.spentHours forKey:@"spent_hours"];
    //    if (self.activity)     [issueDict setObject:self.activity.index forKey:@"activity_id"];
    if (self.issueDescription)  [issueDict setObject:self.issueDescription forKey:@"description"];
    if (self.tracker.index)      [issueDict setObject:self.tracker.index forKey:@"tracker_id"];
    if (self.priority.index)     [issueDict setObject:self.priority.index forKey:@"priority_id"];
    if (self.fixedVersion.index) [issueDict setObject:self.fixedVersion.index forKey:@"fixed_version_id"];
    return issueDict;
}

+ (RKIssue *)issueForIssueDict:(NSDictionary *)issueDict
{
    RKIssue *anIssue = [[RKIssue alloc] init];
    anIssue.index       = [issueDict objectForKey:@"id"];
    anIssue.subject     = [issueDict objectForKey:@"subject"];
    anIssue.spentHours  = [issueDict objectForKey:@"spent_hours"];
    anIssue.status      = [RKParseHelper valueForDict:[issueDict objectForKey:@"status"]];
    anIssue.author      = [RKParseHelper valueForDict:[issueDict objectForKey:@"author"]];
    anIssue.doneRatio   = [issueDict objectForKey:@"done_ratio"];
    anIssue.assignedTo  = [RKParseHelper valueForDict:[issueDict objectForKey:@"assigned_to"]];
    anIssue.createdOn   = [RKParseHelper dateForString:[issueDict objectForKey:@"created_on"]];
    anIssue.subject     = [issueDict objectForKey:@"subject"];
    anIssue.updatedOn   = [RKParseHelper dateForString:[issueDict objectForKey:@"updated_on"]];
    anIssue.issueDescription = [issueDict objectForKey:@"description"];
    anIssue.tracker     = [RKParseHelper valueForDict:[issueDict objectForKey:@"tracker"]];
    anIssue.index       = [issueDict objectForKey:@"id"];
    anIssue.startDate   = [RKParseHelper dateForString:[issueDict objectForKey:@"start_date"]];
    anIssue.dueDate     = [RKParseHelper dateForString:[issueDict objectForKey:@"due_date"]];
    anIssue.priority    = [RKParseHelper valueForDict:[issueDict objectForKey:@"priority"]];
    anIssue.fixedVersion = [RKParseHelper valueForDict:[issueDict objectForKey:@"fixed_version"]];
    return anIssue;
}

@end
