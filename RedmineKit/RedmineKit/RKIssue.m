//
//  Issue.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKIssue.h"
#import "RKRedmine.h"
#import "SBJSON.h"
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
@synthesize estimatedHours=_estimatedHours;
@synthesize tracker=_tracker;
@synthesize index=_index;
@synthesize startDate=_startDate;
@synthesize dueDate=_dueDate;
@synthesize priority=_priority;
@synthesize project=_project;
@synthesize issueDescription=_issueDescription;
@synthesize journals=_journals;
@synthesize parentTask=_parentTask;
@synthesize category=_category;


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ #%@ (%@): %@\n author: %@\n assigned to: %@\n due: %@",
            self.tracker.name, self.index, self.status.name, self.subject, self.author.name, self.assignedTo, self.dueDate];
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
    _journals                   = [[NSMutableArray alloc] init];
    if (!error) {
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSDictionary *issueDict = [jsonDict objectForKey:@"issue"];
        NSArray *journalsDict   = [issueDict objectForKey:@"journals"];
        for (NSDictionary *journalDict in journalsDict) {
            RKJournal *aJournal = [[RKJournal alloc] init];
            aJournal.index      = [journalDict objectForKey:@"id"];
            aJournal.createdOn  = [RKParseHelper dateForString:[journalDict objectForKey:@"created_on"]];
            aJournal.user       = [RKParseHelper valueForDict:[journalDict objectForKey:@"user"]];
            aJournal.notes      = [journalDict objectForKey:@"notes"];
            aJournal.details    = [[NSMutableArray alloc] init];
            for (NSDictionary *detailDict in [journalDict objectForKey:@"details"]) {
                RKJournalDetail *journalDetail = [[RKJournalDetail alloc] init];
                journalDetail.theNewValue  = [detailDict objectForKey:@"new_value"];
                journalDetail.property     = [detailDict objectForKey:@"property"];
                journalDetail.theOldValue  = [detailDict objectForKey:@"old_value"];
                journalDetail.name         = [detailDict objectForKey:@"name"];
                [aJournal.details addObject:journalDetail];
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

- (RKIssueOptions *)updateOptions
{
    if (!self.project.redmine.loggedIn) [self.project.redmine login];
    
    RKIssueOptions *options         = [[RKIssueOptions alloc] init];

    NSString *urlString             = [NSString stringWithFormat:@"%@/issues/%@?key=%@", 
                                       self.project.redmine.serverAddress, 
                                       self.index, 
                                       self.project.redmine.apiKey];
    NSURL *url                      = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] initWithURL:url];
    NSHTTPURLResponse *response     = nil;
    NSError *error                  = nil;
    NSData *data                    = [NSURLConnection sendSynchronousRequest:request 
                                                            returningResponse:&response
                                                                        error:&error];
    if (!error) {        
        TFHpple *doc        = [[TFHpple alloc] initWithHTMLData:data];
        options.trackers    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_tracker_id']/option"];
        options.statuses    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_status_id']/option"];
        options.priorities  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_priority_id']/option"];
        options.categories  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_category_id']/option"];
        options.versions    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_fixed_version_id']/option"];
        options.assignableUsers = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_assigned_to_id']/option"];
        options.activities  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='time_entry_activity_id']/option"];
    } else {
        NSLog(@"Error fetching issue update options: %@ (HTTP status code: %d)", [error localizedDescription], [response statusCode]);
    }
    
    return options;
}

- (BOOL)postUpdateWithNotes:(NSString *)notes
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *issueDict = [self issueDictWithNotes:notes];
    [jsonDict setObject:issueDict forKey:@"issue"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/issues/%@.json?key=%@", self.project.redmine.serverAddress, self.index, self.project.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
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
        return YES;
    }
}

- (BOOL)postTimeEntry:(RKTimeEntry *)entry
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
    {
        if (self.index)             [entryDict setObject:self.index forKey:@"issue_id"];
        if (entry.activity.index)   [entryDict setObject:entry.activity.index forKey:@"activity_id"];
        if (entry.issueIndex)       [entryDict setObject:entry.issueIndex forKey:@"issue_id"];
        if (entry.spentOn)          [entryDict setObject:[RKParseHelper shortDateStringFromDate:entry.spentOn] forKey:@"spent_on"];
        if (entry.hours)            [entryDict setObject:entry.hours forKey:@"hours"];
        if (entry.comments)         [entryDict setObject:entry.comments forKey:@"comments"];
    }
    [jsonDict setObject:entryDict forKey:@"time_entry"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/time_entries.json?key=%@", self.project.redmine.serverAddress, self.project.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
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
    if (self.category.index)    [issueDict setObject:self.category.index forKey:@"category_id"];
    if (self.parentTask)    [issueDict setObject:self.parentTask forKey:@"parent"];
    if (self.estimatedHours) [issueDict setObject:self.estimatedHours forKey:@"estimated_hours"];
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
    anIssue.startDate   = [RKParseHelper dateForShortDateString:[issueDict objectForKey:@"start_date"]];
    anIssue.dueDate     = [RKParseHelper dateForShortDateString:[issueDict objectForKey:@"due_date"]];
    anIssue.priority    = [RKParseHelper valueForDict:[issueDict objectForKey:@"priority"]];
    anIssue.fixedVersion = [RKParseHelper valueForDict:[issueDict objectForKey:@"fixed_version"]];
    anIssue.category    = [RKParseHelper valueForDict:[issueDict objectForKey:@"category"]];
    anIssue.parentTask  = [[issueDict objectForKey:@"parent"] objectForKey:@"id"];
    anIssue.estimatedHours = [issueDict objectForKey:@"estimated_hours"];
    return anIssue;
}

- (id)copyWithZone:(NSZone *)zone
{
    RKIssue *anIssue = [[RKIssue alloc] init];
    anIssue.index       = [self.index copy];
    anIssue.subject     = [self.subject copy];
    anIssue.spentHours  = [self.spentHours copy];
    anIssue.status      = [self.status copy];
    anIssue.author      = [self.author copy];
    anIssue.doneRatio   = [self.doneRatio copy];
    anIssue.assignedTo  = [self.assignedTo copy];
    anIssue.createdOn   = [self.createdOn copy];
    anIssue.subject     = [self.subject copy];
    anIssue.updatedOn   = [self.updatedOn copy];
    anIssue.issueDescription = [self.issueDescription copy];
    anIssue.tracker     = [self.tracker copy];
    anIssue.index       = [self.index copy];
    anIssue.startDate   = [self.startDate copy];
    anIssue.dueDate     = [self.dueDate copy];
    anIssue.priority    = [self.priority copy];
    anIssue.fixedVersion = [self.fixedVersion copy];
    anIssue.category    = [self.category copy];
    anIssue.parentTask  = [self.parentTask copy];
    anIssue.estimatedHours = [self.estimatedHours copy];
    anIssue.project     = [self.project copy];
    return anIssue;
}

@end
