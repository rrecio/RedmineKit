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
        redmine.serverAddress = @"http://projetos.owera.com.br";
        redmine.username = @"testuser";
        redmine.password = @"test123";
        [redmine login];
        
        RKProject *projetoRedmine = [redmine projectForIdentifier:@"testproject"];
//        projetoRedmine.sortIssuesBy = RKIssueSortByAssignedTo;
        for (RKIssue *issue in [projetoRedmine issues]) {
            NSLog(@"%@: %@", issue.index, issue.assignedTo.name);
        }
        
        
//        RKIssue *issue = [owera issueForIndex:[NSNumber numberWithInt:382]];
//        
//        // issue update history
//        for (RKJournal *journal in [issue journals]) {
//            NSLog(@"%@ %@: %@", journal.createdOn, journal.user.name, journal.notes);
//        }
    }
}
