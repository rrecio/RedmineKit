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

@property (nonatomic, retain) NSNumber *issueIndex;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) RKValue *activity;
@property (nonatomic, retain) RKValue *user;
@property (nonatomic, retain) NSDate *updatedOn;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSDate *spentOn;
@property (nonatomic, retain) NSNumber *hours;
@property (nonatomic, retain) RKValue *project;

@end
