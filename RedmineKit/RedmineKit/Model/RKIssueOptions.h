//
//  NewIssueOptions.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKIssueOptions : NSObject

@property (nonatomic, retain) NSArray *trackers;
@property (nonatomic, retain) NSArray *statuses;
@property (nonatomic, retain) NSArray *priorities;
@property (nonatomic, retain) NSArray *versions;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *assignableUsers;
@property (nonatomic, retain) NSArray *activities;

@end
