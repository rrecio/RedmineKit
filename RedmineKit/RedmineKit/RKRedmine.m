//
//  Redmine.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKRedmine.h"
#import "RKParseHelper.h"
#import "TFHpple.h"
#import "JSON.h"

@interface RKRedmine ()
- (NSString *)authKey;
- (void)fetchApiKey;
- (void)login;
@end

@implementation RKRedmine

@synthesize username=_user;
@synthesize password=_pass;
@synthesize apiKey=_apiKey;
@synthesize serverAddress=_serverAddress;


#pragma mark - Initializers

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        
        self.apiKey = [stdDefaults objectForKey:@"apikey"];
    }
    return self;
}

#pragma mark - Internals

- (void)login
{
    NSString *urlString     = [NSString stringWithFormat:@"%@/login", self.serverAddress];
    NSURL *url              = [NSURL URLWithString:urlString];
    
    NSMutableString *postString    = [[NSMutableString alloc] init];
    NSString *auth_key = [[self authKey] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [postString appendFormat:@"authenticity_token=%@", auth_key];
    [postString appendFormat:@"&username=%@", _user];
    [postString appendFormat:@"&password=%@", _pass];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error              = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error logging in: %@", [error localizedDescription]);
    } else {
        [self fetchApiKey];
    }
}

- (void)fetchApiKey
{
    NSString *urlString     = [NSString stringWithFormat:@"%@/my/account", self.serverAddress];
    NSURL *url              = [NSURL URLWithString:urlString];
    NSData  *data           = [NSData dataWithContentsOfURL:url];
    TFHpple *doc            = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements       = [doc searchWithXPathQuery:@"//pre[@id='api-access-key']"];
    if ([elements count] > 0) {
        TFHppleElement *input   = [elements objectAtIndex:0];
        self.apiKey         = [input content];
    }
}

- (NSString *)authKey
{
    NSString *urlString     = [NSString stringWithFormat:@"%@/login", self.serverAddress];
    NSURL *url              = [NSURL URLWithString:urlString];
    NSData  *data           = [NSData dataWithContentsOfURL:url];
    TFHpple *doc            = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements       = [doc searchWithXPathQuery:@"//input[@name='authenticity_token']"];
    NSString *auth_key      = nil;
    if ([elements count] > 0) {
        TFHppleElement *input   = [elements objectAtIndex:0];
        auth_key      = [input objectForKey:@"value"];
    }
    return auth_key;
}

#pragma mark - Redmine Interface

- (NSArray *)projects
{
    if (_projects == nil) {
        _projects = [[NSMutableArray alloc] init];
        projectPage = 1;
        [self loadMoreProjects];
    }
    return _projects;
}

- (void)loadMoreProjects
{
    if ([self isLastPage]) {
        NSLog(@"It's last page!");
        return;
    }
    NSString *urlString         = [NSString stringWithFormat:@"%@/projects.json?page=%d&key=%@", self.serverAddress, projectPage++, self.apiKey];
    NSURL *url                  = [NSURL URLWithString:urlString];
    NSString *responseString    = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *jsonDict      = [responseString JSONValue];
    totalProjects               = [[jsonDict objectForKey:@"total_count"] intValue];
    pageOffset                  = [[jsonDict objectForKey:@"offset"] intValue];
    NSArray *projectsDict = [jsonDict objectForKey:@"projects"];
    for (NSDictionary *projectDict in projectsDict) {
        RKProject *aProject     = [RKProject projectForProjectDict:projectDict];
        aProject.redmine        = self;
        [_projects addObject:aProject];
    }
}

- (BOOL)isLastPage
{
    return ((pageOffset+25 > totalProjects) && (totalProjects != 0));
}

- (RKProject *)projectForIdentifier:(NSString *)identifier
{
    RKProject *projectFound = nil;
    for (RKProject *project in [self projects]) {
        if ([project.identifier isEqualToString:identifier]) {
            projectFound = project;
            break;
        }
    }
    if (projectFound == nil) {
        NSString *urlString     = [NSString stringWithFormat:@"%@/projects/%@.json?key=%@", self.serverAddress, identifier, self.apiKey];
        NSURL *url              = [NSURL URLWithString:urlString];
        NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSDictionary *projectDict = [jsonDict objectForKey:@"project"];
        RKProject *aProject       = [RKProject projectForProjectDict:projectDict];
        aProject.redmine        = self;
        [_projects addObject:aProject];
        projectFound = aProject;
    }
    return projectFound;
}

- (RKProject *)projectForIndex:(NSNumber *)index
{
    return [self projectForIdentifier:[index stringValue]];
}

- (NSArray *)refreshProjects
{
    _projects = nil;
    return [self projects];
}

- (RKIssue *)issueForIndex:(NSNumber *)index
{
    NSString *urlString         = [NSString stringWithFormat:@"%@/issues/%@.json?key=%@", self.serverAddress, index, self.apiKey];
    NSURL *url                  = [NSURL URLWithString:urlString];
    NSError *error              = nil;
    NSString *responseString    = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSDictionary *issueDict = [jsonDict objectForKey:@"issue"];
        RKIssue *anIssue        = [RKIssue issueForIssueDict:issueDict];
        anIssue.project         = [self projectForIndex:[[issueDict objectForKey:@"project"] objectForKey:@"id"]];
        NSLog(@"Got issue: %@ from project: %@", anIssue, anIssue.project);
        return anIssue;
    } else {
        NSLog(@"Error retrieving issue: %@", [error localizedDescription]);
        return nil;
    }
}

@end
