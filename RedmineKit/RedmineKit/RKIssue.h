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
@interface RKIssue : NSObject <NSCopying>

@property (strong, nonatomic) RKValue *status;
@property (strong, nonatomic) RKValue *author;
@property (strong, nonatomic) NSNumber *doneRatio;
@property (strong, nonatomic) RKValue *assignedTo;
@property (strong, nonatomic) RKValue *fixedVersion;
@property (strong, nonatomic) NSDate *createdOn;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSDate *updatedOn;
@property (strong, nonatomic) NSNumber *spentHours;
@property (strong, nonatomic) NSNumber *estimatedHours;
@property (strong, nonatomic) RKValue *tracker;
@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *dueDate;
@property (strong, nonatomic) RKValue *priority;
@property (strong, nonatomic) RKProject *project;
@property (strong, nonatomic) NSString *issueDescription;
@property (strong, nonatomic) NSMutableArray *journals;
@property (strong, nonatomic) NSNumber *parentTask;
@property (strong, nonatomic) RKValue *category;

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
