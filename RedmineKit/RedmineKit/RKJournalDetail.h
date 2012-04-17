//
//  JournalDetail.h
//  RedmineKit
//
//  Created by Rodrigo Recio on 15/11/11.
//  Copyright (c) 2011 Owera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKJournalDetail : NSObject

@property (strong, nonatomic) NSString *theNewValue;
@property (strong, nonatomic) NSString *property;
@property (strong, nonatomic) NSString *theOldValue;
@property (strong, nonatomic) NSString *name;

@end
