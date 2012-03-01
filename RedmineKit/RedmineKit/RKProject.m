//
//  Project.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKProject.h"
#import "RKRedmine.h"
#import "SBJSON.h"
#import "TFHpple.h"
#import "RKParseHelper.h"
#import "RKRedmine.h"
#import "RKValue.h"

@interface RKProject ()
- (NSString *)stringForSortBySelection;
@end

@implementation RKProject

@synthesize identifier=_identifier;
@synthesize homepage=_homepage;
@synthesize createdOn=_createdOn;
@synthesize name=_name;
@synthesize updatedOn=_updatedOn;
@synthesize projectDescription=_projectDescription;
@synthesize index=_index;
@synthesize parent=_parent;
@synthesize issues=_issues;
@synthesize redmine=_redmine;
@synthesize sortIssuesBy=_sortIssuesBy;
@synthesize orderIssuesDesc=_orderIssuesDesc;

#pragma mark - Here is What's Really Important

- (NSMutableArray *)issues
{
    if (!_issues) {
        _issues  = [NSMutableArray array];
        issuesPageCount = 1;
        pageOffset = 0;
        totalIssues = 0;
        [self loadMoreIssues];
    }
    return _issues;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.index];
}

- (NSString *)stringForSortBySelection
{
    NSString *string = nil;
    switch (self.sortIssuesBy) {
        case RKIssueSortById:
            string = @"id";
            break;
        case RKIssueSortByTracker:
            string = @"tracker";
            break;
        case RKIssueSortByStatus:
            string = @"status";
            break;
        case RKIssueSortByPriority:
            string = @"priority";
            break;
        case RKIssueSortByCategory:
            string = @"category";
            break;
        case RKIssueSortByAssignedTo:
            string = @"assigned_to";
            break;
        case RKIssueSortByFixedVersion:
            string = @"fixed_version";
            break;
        case RKIssueSortByStartDate:
            string = @"start_date";
            break;
        case RKIssueSortByDueDate:
            string = @"due_date";
            break;
        case RKIssueSortByEstimatedHours:
            string = @"estimated_hours";
            break;
        case RKIssueSortByDone:
            string = @"done";
            break;
        default:
            string = @"id";
            break;
    }
    return string;
}

- (void)loadMoreIssues
{
    if ([self isLastPage]) {
        return;
    }
    NSString *order = [self.orderIssuesDesc boolValue] ? @":desc" : @"";
    NSString *sortBy = [self stringForSortBySelection];
    NSString *sort = [NSString stringWithFormat:@"sort=%@%@", sortBy, order];
    NSString *urlString     = [NSString stringWithFormat:@"%@/projects/%@/issues.json?page=%d&key=%@&%@", self.redmine.serverAddress, self.index, issuesPageCount++, self.redmine.apiKey, sort];
    NSURL *url              = [NSURL URLWithString:urlString];
    NSError *error          = nil;
    NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSArray *issuesDict = [jsonDict objectForKey:@"issues"];
        totalIssues = [[jsonDict objectForKey:@"total_count"] intValue];
        pageOffset  = [[jsonDict objectForKey:@"offset"] intValue];
        for (NSDictionary *issueDict in issuesDict) {
            RKIssue *anIssue    = [RKIssue issueForIssueDict:issueDict];
            anIssue.project     = self;
            [_issues addObject:anIssue];
        }
    } else {
        NSLog(@"Error loading more issues: %@. URL string: %@", [error localizedDescription], urlString);
    }
}

- (BOOL)isLastPage
{
    return ((pageOffset+25 > totalIssues) && (totalIssues != 0));
}

- (NSMutableArray *)refreshIssues
{
    _issues = nil;
    return [self issues];
}

- (RKIssueOptions *)newIssueOptions
{
    if (!self.redmine.loggedIn) [self.redmine login];
    
    RKIssueOptions *newIssueOptions = [[RKIssueOptions alloc] init];
    
    NSString *urlString     = [NSString stringWithFormat:@"%@/projects/%@/issues/new?key=%@", self.redmine.serverAddress, self.index, self.redmine.apiKey];
    NSURL *url              = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] initWithURL:url];
    NSHTTPURLResponse *response     = nil;
    NSError *error                  = nil;
    NSData *data                    = [NSURLConnection sendSynchronousRequest:request 
                                                            returningResponse:&response
                                                                        error:&error];
    if (!error) {
        TFHpple *doc            = [[TFHpple alloc] initWithHTMLData:data];    
        newIssueOptions.trackers    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_tracker_id']/option"];
        newIssueOptions.statuses    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_status_id']/option"];
        newIssueOptions.priorities  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_priority_id']/option"];
        newIssueOptions.categories  = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_category_id']/option"];
        newIssueOptions.versions    = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_fixed_version_id']/option"];
        newIssueOptions.assignableUsers = [RKParseHelper arrayForElementsOfDoc:doc onXPath:@"//select[@id='issue_assigned_to_id']/option"];
    } else {
            NSLog(@"Error fetching new issue options: %@ (HTTP status code: %d)", [error localizedDescription], [response statusCode]);
    }
        
    return newIssueOptions;
}

- (RKIssue *)issueForIndex:(NSNumber *)index
{
    RKIssue *issue = nil;
    for (RKIssue *anIssue in [self issues]) {
        if ([anIssue.index isEqualToNumber:index]) {
            issue = anIssue;
        }
    }
    if (issue == nil) {
        NSString *urlString     = [NSString stringWithFormat:@"%@/issues/%@.json?key=%@", self.redmine.serverAddress, self.index, self.redmine.apiKey];
        NSURL *url              = [NSURL URLWithString:urlString];
        NSError *error          = nil;
        NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            NSDictionary *jsonDict  = [responseString JSONValue];
            NSDictionary *issueDict = [jsonDict objectForKey:@"issue"];
            RKIssue *anIssue    = [RKIssue issueForIssueDict:issueDict];
            anIssue.project     = self;
            [_issues addObject:anIssue];
        } else {
            NSLog(@"Error retrieving issue: %@", [error localizedDescription]);
        }
    }
    return issue;
}

- (BOOL)postNewIssue:(RKIssue *)issue
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *issueDict = [issue issueDictWithNotes:nil];
    [issueDict setObject:self.index forKey:@"project_id"];
    [jsonDict setObject:issueDict forKey:@"issue"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/issues.json?key=%@", self.redmine.serverAddress, self.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSError *error      = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    if (error) {
        NSLog(@"Error posting new issue: %@. Response from server: %@", [error localizedDescription], responseString);
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)postProjectUpdate {
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:[self projectDict] forKey:@"project"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/projects/%@.json?key=%@", self.redmine.serverAddress, self.index, self.redmine.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSError *error      = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    if (error) {
        NSLog(@"Error updating project: %@. URL string: %@", [error localizedDescription], urlString);
        return NO;
    } else {
        NSLog(@"Project update posted successfully. Response:\n%@", responseString);
        return YES;
    }
}

+ (RKProject *)projectForProjectDict:(NSDictionary *)projectDict
{
    RKProject *aProject = [[RKProject alloc] init];
    aProject.identifier     = [projectDict objectForKey:@"identifier"];
    aProject.name           = [projectDict objectForKey:@"name"];
    aProject.homepage       = [projectDict objectForKey:@"homepage"];
    aProject.createdOn      = [RKParseHelper dateForString:[projectDict objectForKey:@"created_on"]];
    aProject.updatedOn      = [RKParseHelper dateForString:[projectDict objectForKey:@"updated_on"]];
    aProject.projectDescription = [projectDict objectForKey:@"description"];
    aProject.index          = [projectDict objectForKey:@"id"];
    aProject.parent         = [RKParseHelper valueForDict:[projectDict objectForKey:@"parent"]];
    return aProject;
}

- (id)copyWithZone:(NSZone *)zone
{
    RKProject *copy = [[RKProject alloc] init];
    copy.identifier = [self.identifier copy];
    copy.homepage = [self.homepage copy];
    copy.createdOn = [self.createdOn copy];
    copy.name = [self.name copy];
    copy.updatedOn = [self.updatedOn copy];
    copy.projectDescription = [self.projectDescription copy];
    copy.index = [self.index copy];
    copy.parent = [self.parent copy];
    copy.redmine = [self.redmine copy];
    return copy;
}

- (NSDictionary *)projectDict
{
    NSMutableDictionary *projectDict = [[NSMutableDictionary alloc] init];
    if (self.identifier)            [projectDict setObject:self.identifier          forKey:@"identifier"];
    if (self.name)                  [projectDict setObject:self.name                forKey:@"name"];
    if (self.projectDescription)    [projectDict setObject:self.projectDescription  forKey:@"description"];
    return projectDict;
}

@end
