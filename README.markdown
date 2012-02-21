# RedmineKit

Objective-C library for using Redmine

# Usage Instructions

## Authentication

    RKRedmine *myRedmine = [[RKRedmine alloc] init];
    myRedmine.serverAddress = @"http://www.myredmine.com";
    myRedmine.username = @"username";
    myRedmine.password = @"my_password";
    [myRedmine login];

## Listing Projects

    NSArray *projects = [myRedmine projects];
    for (RKProject *project in projects) {
        NSLog(@"=> %@", project.name);
    }

## Listing Project Issues and it's update history (journals)

    RKProject *myProject = [myRedmine projectForIndex:myProjectIndex];
    myProject.sortIssuesBy = RKIssueSortByAssignedTo;
    myProject.orderIssuesDesc = [NSNumber numberWithBool:YES];
    NSArray *issues = [myProject issues];
    for (RKIssue *issue in issues) {
        NSLog(@"=> %@", issue.subject);
        
        NSArray *journals = [issue journals];
        for (RKJournal *journal in journals) {
            NSLog(@"==> %@: %@", journal.createdOn, journal.notes);
        }
    }

## Creating Issues

    RKIssue *myNewIssue = [[RKIssue alloc] init];
    myNewIssue.subject = @"My issue's subject";
    myNewIssue.issueDescription = @"This is how I describe an issue";

    RKIssueOptions *newIssueOptions = [myProject newIssueOptions];
    myNewIsuse.tracker = [[newIssueOptions trackers] objectAtIndex:chosenTrackerIndex];

    [myProject postNewIssue:myNewIssue];

## Updating Issues

    RKIssue *myIssue = [myRedmine issueForIndex:myIssueIndex];
    RKIssueOptions *updateOptions = [myIssue updateOptions];
    myIssue.assignedTo = [updateOptions.assignableUsers objectAtIndex:assignedUserIndex];
    [myIssue postUpdateWithNotes:@"Assigned to user X for review"];

## Posting a Time Entry

    RKIssue *myIssue = [myRedmine issueForIndex:myIssueIndex];
    RKIssueOptions *options = [myIssue updateOptions];
    
    RKTimeEntry *entry = [[RKTimeEntry alloc] init];
    entry.spentOn = [options.activities objectAtIndex:activityIndex];
    entry.hours = [NSNumber numberWithFloat:3.5];
    entry.comments = @"Here it goes a comment for this time entry"

    [myIssue postTimeEntry:entry];