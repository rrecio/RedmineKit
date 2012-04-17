//
//  ParseHelper.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 17/02/12.
//  Copyright (c) 2012 Owera. All rights reserved.
//

#import "RKParseHelper.h"
#import "TFHpple.h"
#import "RKValue.h"

@implementation RKParseHelper

#pragma mark - Helper Methods

+ (NSArray *)arrayForElementsOfDoc:(TFHpple *)doc onXPath:(NSString *)xpath
{
    NSArray *elements      = [doc searchWithXPathQuery:xpath];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (TFHppleElement *e in elements) {
        if ([e content] != nil || 
            [[e objectForKey:@"value"] isEqualToString:@""] == NO ||
            [e objectForKey:@"value"] != nil) {
            [array addObject:[self valueForElement:e]];
        }
    }
    return array;
}

+ (RKValue *)valueForElement:(TFHppleElement *)e
{
    RKValue *value = [[RKValue alloc] init];
    value.name = [e content];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *indexNumber = [f numberFromString:[e objectForKey:@"value"]];
    value.index = indexNumber;
    return value;
}

+ (NSDictionary *)dictFromValue:(RKValue *)value
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:value.name forKey:@"name"];
    [dict setObject:value.index forKey:@"id"];
    return dict;
}

+ (NSString *)shortDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    return [dateFormatter stringFromDate:date];
}

+ (RKValue *)valueForDict:(NSDictionary *)dict
{
    RKValue *value = [[RKValue alloc] init];
    value.name = [dict objectForKey:@"name"];
    value.index = [dict objectForKey:@"id"];
    return value;
}

+ (NSDate *)dateForShortDateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSDate *)dateForString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss Z"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}


@end
