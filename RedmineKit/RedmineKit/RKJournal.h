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

@property (nonatomic) NSDate *createdOn;
@property (nonatomic) RKValue *user;
@property (nonatomic) NSMutableArray *details;
@property (nonatomic) NSString *notes;
@property (nonatomic) NSNumber *index;

@end
