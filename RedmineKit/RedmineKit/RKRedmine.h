//
//  Redmine.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RKProject.h"
#import "RKIssue.h"
#import "RKJournal.h"
#import "RKTimeEntry.h"
#import "RKJournalDetail.h"
#import "RKValue.h"
#import "RKIssueOptions.h"

@interface RKRedmine : NSObject <NSCoding, NSCopying>
{
    NSMutableArray *_projects;
    NSUInteger projectPage;
    NSUInteger totalProjects;
    NSUInteger pageOffset;
}

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *serverAddress;
@property BOOL loggedIn;

- (void)login;
/**
 * Method that show the projects available on this redmine instance
 * On the first run, it loads the data from server, after that, it gets
 * from cache. To reload the data see the refreshProjects: method.
 */
- (NSArray *)projects;

/**
 * Method that deletes the current cached projects data and download
 * it again from server.
 */
- (NSArray *)refreshProjects;

/**
 * Method for looking up a project using a identifier
 */
- (RKProject *)projectForIdentifier:(NSString *)identifier;

- (RKIssue *)issueForIndex:(NSNumber *)index;

/**
 * Method that paginates the items, loading 25 more items and add them
 * to the projects array each time it's called. (unless it's the last page).
 */
- (void)loadMoreProjects;

/**
 * method used to figure out if all projects were already loaded;
 */
- (BOOL)isLastPage;

- (BOOL)postNewProject:(RKProject *)project;

@end
