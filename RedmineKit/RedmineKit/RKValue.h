//
//  Value.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKValue : NSObject <NSCopying>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *index;

- (id)initWithName:(NSString *)name andIndex:(NSNumber *)index;
+ (RKValue *)valueWithIndex:(NSNumber *)index;
+ (RKValue *)valueWithName:(NSString *)name;
+ (RKValue *)valueWithName:(NSString *)name andIndex:(NSNumber *)index;

@end
