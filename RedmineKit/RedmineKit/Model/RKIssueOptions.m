//
//  NewIssueOptions.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKIssueOptions.h"

@implementation RKIssueOptions

@synthesize trackers=_trackers;
@synthesize statuses=_statuses;
@synthesize categories=_categories;
@synthesize versions=_versions;
@synthesize priorities=_priorities;
@synthesize assignableUsers=_assignableUsers;
@synthesize activities=_activities;

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [description appendString:@"=> issue options\n"];
    [description appendFormat:@"trackers: %@", self.trackers];
    [description appendFormat:@"statuses: %@", self.statuses];
    [description appendFormat:@"categories: %@", self.categories];
    [description appendFormat:@"versions: %@", self.versions];
    [description appendFormat:@"priorities: %@", self.priorities];
    [description appendFormat:@"assignable users: %@", self.assignableUsers];
    [description appendFormat:@"activities: %@", self.activities];
    return description;
}

@end
