//
//  JournalDetail.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKJournalDetail : NSObject

@property (nonatomic, retain) NSString *theNewValue;
@property (nonatomic, retain) NSString *property;
@property (nonatomic, retain) NSString *theOldValue;
@property (nonatomic, retain) NSString *name;

@end
