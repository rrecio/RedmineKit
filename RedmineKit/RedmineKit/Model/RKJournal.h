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

@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) RKValue *user;
@property (nonatomic, retain) NSMutableArray *details;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSNumber *index;

@end
