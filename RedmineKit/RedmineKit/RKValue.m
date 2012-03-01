//
//  Value.m
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import "RKValue.h"

@implementation RKValue

@synthesize name=_name;
@synthesize index=_index;

+ (RKValue *)valueWithName:(NSString *)name
{
    return [RKValue valueWithName:name andIndex:nil];
}

+ (RKValue *)valueWithIndex:(NSNumber *)index
{
    return [RKValue valueWithName:nil andIndex:index];
}

+ (RKValue *)valueWithName:(NSString *)name andIndex:(NSNumber *)index
{
    RKValue *value = [[RKValue alloc] initWithName:name andIndex:index];
    return value;
}

- (id)initWithName:(NSString *)name andIndex:(NSNumber *)index {
    self = [super init];
    if (self) {
        self.name = name;
        self.index = index;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@. %@", self.index, self.name];
}

- (BOOL)isEqual:(RKValue *)otherValue
{
    BOOL indexEqual;
    BOOL nameEqual;
    if (otherValue.index == nil) {
        indexEqual = self.index == nil;
    } else {
        indexEqual = [self.index isEqualToNumber:otherValue.index];
    }
    
    if (otherValue.name == nil) {
        nameEqual = self.name == nil;
    } else {
        nameEqual = [self.name isEqualToString:otherValue.name];
    }
    return (indexEqual && nameEqual);
}

- (id)copyWithZone:(NSZone *)zone
{
    RKValue *copy = [[RKValue alloc] init];
    copy.name = [self.name copy];
    copy.index = [self.index copy];
    return copy;
}

@end
