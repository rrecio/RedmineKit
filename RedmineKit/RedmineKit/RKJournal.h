//
//  Journal.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKValue.h"

@interface RKJournal : NSObject

@property (strong, nonatomic) NSDate *createdOn;
@property (strong, nonatomic) RKValue *user;
@property (strong, nonatomic) NSMutableArray *details;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) NSNumber *index;

@end
