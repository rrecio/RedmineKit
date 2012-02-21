//
//  Project.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RKIssueSortById = 1,
    RKIssueSortByTracker = 2,
    RKIssueSortByStatus = 3,
    RKIssueSortByPriority = 4,
    RKIssueSortByCategory = 5, 
    RKIssueSortByAssignedTo = 6,
    RKIssueSortByFixedVersion = 7,
    RKIssueSortByStartDate = 8,
    RKIssueSortByDueDate = 9,
    RKIssueSortByEstimatedHours = 10,
    RKIssueSortByDone = 11
} RKIssueSortBy;

@class RKValue;
@class RKIssue;
@class RKIssueOptions;
@class RKRedmine;
@interface RKProject : NSObject
{
    NSUInteger issuesPageCount;
    NSUInteger totalIssues;
    NSUInteger pageOffset;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *homepage;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *updatedOn;
@property (nonatomic, retain) NSString *projectDescription;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) RKValue *parent;
@property (nonatomic, retain) NSMutableArray *issues;
@property (nonatomic, retain) RKRedmine *redmine;
@property (nonatomic) RKIssueSortBy sortIssuesBy;
@property (nonatomic, retain) NSNumber *orderIssuesDesc;

+ (RKProject *)projectForProjectDict:(NSDictionary *)projectDict;
/**
 * method to get a specific issue
 */
- (RKIssue *)issueForIndex:(NSNumber *)index;

/**
 * method to paginate through issue list (by 25 items per page)
 */
- (void)loadMoreIssues;

/**
 * method used to figure out if all issues were already loaded;
 */
- (BOOL)isLastPage;

/**
 * method to post new issue
 */
- (BOOL)postNewIssue:(RKIssue *)issue;

/**
 * method that gets the currently available options for the new issue on current project
 * (ex.: versions, priorities, project members, etc.)
 */
- (RKIssueOptions *)newIssueOptions;

@end
