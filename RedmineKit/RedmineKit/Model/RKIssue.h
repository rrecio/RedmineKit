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

@property (nonatomic, retain) RKValue *status;
@property (nonatomic, retain) RKValue *author;
@property (nonatomic, retain) NSNumber *doneRatio;
@property (nonatomic, retain) RKValue *assignedTo;
@property (nonatomic, retain) RKValue *fixedVersion;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSDate *updatedOn;
@property (nonatomic, retain) NSNumber *spentHours;
@property (nonatomic, retain) RKValue *tracker;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *dueDate;
@property (nonatomic, retain) RKValue *priority;
@property (nonatomic, retain) RKProject *project;
@property (nonatomic, retain) NSString *issueDescription;
@property (nonatomic, retain) NSMutableArray *journals;
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
