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
#import "SBJSON.h"

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
@synthesize loggedIn;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        self.loggedIn = NO;
        self.apiKey = [stdDefaults objectForKey:@"apikey"];
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    self.username       = [aDecoder decodeObjectForKey:@"username"];
    self.password       = [aDecoder decodeObjectForKey:@"password"];
    self.serverAddress  = [aDecoder decodeObjectForKey:@"serverAddress"];
    self.apiKey         = [aDecoder decodeObjectForKey:@"apiKey"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username      forKey:@"username"];
    [aCoder encodeObject:self.password      forKey:@"password"];
    [aCoder encodeObject:self.serverAddress forKey:@"serverAddress"];
    [aCoder encodeObject:self.apiKey        forKey:@"apiKey"];
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
        if (self.apiKey == nil) [self fetchApiKey];
        self.loggedIn = YES;
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
    if (!_projects) {
        _projects = [[NSMutableArray alloc] init];
        projectPage = 1;
        pageOffset = 0;
        totalProjects = 0;
        [self loadMoreProjects];
    }
    return _projects;
}

- (void)loadMoreProjects
{
    if ([self isLastPage]) {
        return;
    }
    NSString *urlString         = [NSString stringWithFormat:@"%@/projects.json?page=%d&key=%@", self.serverAddress, projectPage++, self.apiKey];
    NSURL *url                  = [NSURL URLWithString:urlString];
    NSError *error              = nil;
    NSString *responseString    = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *jsonDict      = [responseString JSONValue];
    totalProjects               = [[jsonDict objectForKey:@"total_count"] intValue];
    pageOffset                  = [[jsonDict objectForKey:@"offset"] intValue];
    NSArray *projectsDict = [jsonDict objectForKey:@"projects"];
    for (NSDictionary *projectDict in projectsDict) {
        RKProject *aProject     = [RKProject projectForProjectDict:projectDict];
        aProject.redmine        = self;
        [_projects addObject:aProject];
    }
    if (error) {
        NSLog(@"Error loading more projects: %@", [error localizedDescription]);
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
        NSError *error          = nil;
        NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        NSDictionary *jsonDict  = [responseString JSONValue];
        NSDictionary *projectDict = [jsonDict objectForKey:@"project"];
        RKProject *aProject       = [RKProject projectForProjectDict:projectDict];
        aProject.redmine        = self;
        [_projects addObject:aProject];
        projectFound = aProject;
        if (error)
        {
            NSLog(@"Error loading project for identifier: %@", [error localizedDescription]);
        }
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
        return anIssue;
    } else {
        NSLog(@"Error retrieving issue: %@", [error localizedDescription]);
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    RKRedmine *copy = [[RKRedmine alloc] init];
    copy.username = [self.username copy];
    copy.password = [self.password copy];
    copy.serverAddress = [self.serverAddress copy];
    copy.apiKey = [self.apiKey copy];
    return copy;
}

- (BOOL)postNewProject:(RKProject *)project
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:[project projectDict] forKey:@"project"];
    NSString *jsonString = [jsonDict JSONRepresentation];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"new project json string: %@", jsonString);
    NSString *urlString = [NSString stringWithFormat:@"%@/projects.json?key=%@", self.serverAddress, self.apiKey];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSError *error      = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    if (error) {
        NSLog(@"Error posting new project: %@", [error localizedDescription]);
        return NO;
    } else {
        NSLog(@"New project posted successfully. Response:\n%@", responseString);
        return YES;
    }
}

@end
