//
//  ParseHelper.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 17/02/12.
//  Copyright (c) 2012 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFHpple;
@class TFHppleElement;
@class RKValue;

@interface RKParseHelper : NSObject

+ (RKValue *)valueForElement:(TFHppleElement *)e;
+ (NSArray *)arrayForElementsOfDoc:(TFHpple *)doc onXPath:(NSString *)xpath;
+ (NSDictionary *)dictFromValue:(RKValue *)value;
+ (NSString *)shortDateStringFromDate:(NSDate *)date;
+ (RKValue *)valueForDict:(NSDictionary *)dict;
+ (NSDate *)dateForString:(NSString *)dateString;
+ (NSDate *)dateForShortDateString:(NSString *)dateString;

@end
