//
//  main.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RKRedmine.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        RKRedmine *redmine = [[RKRedmine alloc] init];
        redmine.serverAddress = @"http://192.168.229.130";
        redmine.username = @"test";
        redmine.password = @"test";
        [redmine login];
        
//        RKProject *projetoRedmine = [redmine projectForIdentifier:@"testproject"];
////        projetoRedmine.sortIssuesBy = RKIssueSortByAssignedTo;
//        for (RKIssue *issue in [projetoRedmine issues]) {
//            NSLog(@"%@: %@", issue.index, issue.assignedTo.name);
//        }
        
        RKIssue *issue = [redmine issueForIndex:[NSNumber numberWithInt:7]];
        
        // issue update history
        for (RKJournal *journal in [issue journals]) {
            NSLog(@"%@ %@: %@", journal.createdOn, journal.user.name, journal.notes);
            
            NSLog(@"journal details: ");
            
            for (RKJournalDetail *detail in journal.details) {
                NSLog(@"property: %@", detail.property);
            }
        }
    }
}
