//
//  Issue.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKValue;
@class RKIssueOptions;
@class RKProject;
@class RKTimeEntry;
@interface RKIssue : NSObject

@property (nonatomic) RKValue *status;
@property (nonatomic) RKValue *author;
@property (nonatomic) NSNumber *doneRatio;
@property (nonatomic) RKValue *assignedTo;
@property (nonatomic) RKValue *fixedVersion;
@property (nonatomic) NSDate *createdOn;
@property (nonatomic) NSString *subject;
@property (nonatomic) NSDate *updatedOn;
@property (nonatomic) NSNumber *spentHours;
@property (nonatomic) RKValue *tracker;
@property (nonatomic) NSNumber *index;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) RKValue *priority;
@property (nonatomic) RKProject *project;
@property (nonatomic) NSString *issueDescription;
@property (nonatomic) NSMutableArray *journals;
//@property (nonatomic, retain) Value *activity;

+ (RKIssue *)issueForIssueDict:(NSDictionary *)issueDict;

- (NSMutableArray *)refreshJournals;

/**
 * method that gets the currently available options for updating the existing issue on
 * the current project
 */
- (RKIssueOptions *)updateOptions;

- (BOOL)postUpdateWithNotes:(NSString *)notes;

- (BOOL)postTimeEntry:(RKTimeEntry *)entry;

- (NSMutableDictionary *)issueDictWithNotes:(NSString *)notes;

@end
