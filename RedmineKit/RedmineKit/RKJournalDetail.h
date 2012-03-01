//
//  JournalDetail.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKJournalDetail : NSObject

@property (nonatomic) NSString *theNewValue;
@property (nonatomic) NSString *property;
@property (nonatomic) NSString *theOldValue;
@property (nonatomic) NSString *name;

@end
