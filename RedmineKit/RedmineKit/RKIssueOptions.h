//
//  NewIssueOptions.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKIssueOptions : NSObject

@property (nonatomic) NSArray *trackers;
@property (nonatomic) NSArray *statuses;
@property (nonatomic) NSArray *priorities;
@property (nonatomic) NSArray *versions;
@property (nonatomic) NSArray *categories;
@property (nonatomic) NSArray *assignableUsers;
@property (nonatomic) NSArray *activities;

@end
