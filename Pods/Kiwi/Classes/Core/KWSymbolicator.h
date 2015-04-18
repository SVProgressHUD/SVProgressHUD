//
//  KWSymbolicator.h
//  Kiwi
//
//  Created by Jerry Marino on 4/28/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

long kwCallerAddress(void);

@interface NSString (KWShellCommand)

+ (NSString *)stringWithShellCommand:(NSString *)command arguments:(NSArray *)arguments;

@end
