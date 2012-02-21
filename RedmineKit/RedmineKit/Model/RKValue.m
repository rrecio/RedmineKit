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

+ (RKValue *)valueWithIndex:(NSNumber *)index
{
    RKValue *value = [[RKValue alloc] initWithName:nil andIndex:index];
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

@end
