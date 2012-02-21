//
//  Value.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKValue : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *index;

- (id)initWithName:(NSString *)name andIndex:(NSNumber *)index;
+ (RKValue *)valueWithIndex:(NSNumber *)index;

@end
