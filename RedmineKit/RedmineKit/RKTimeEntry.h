//
//  TimeEntry.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKValue;
@interface RKTimeEntry : NSObject

@property (nonatomic) NSNumber *issueIndex;
@property (nonatomic) NSDate *createdOn;
@property (nonatomic) RKValue *activity;
@property (nonatomic) RKValue *user;
@property (nonatomic) NSDate *updatedOn;
@property (nonatomic) NSString *comments;
@property (nonatomic) NSNumber *index;
@property (nonatomic) NSDate *spentOn;
@property (nonatomic) NSNumber *hours;
@property (nonatomic) RKValue *project;

@end
