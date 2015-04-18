//
//  KWBeNilMatcher.h
//  iOSFalconCore
//
//  Created by Luke Redpath on 14/01/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWMatcher.h"

@interface KWNilMatcher : KWMatcher

- (void)beNil;
- (void)beNonNil;

- (void)beNil:(BOOL)workaroundArgument;
- (void)beNonNil:(BOOL)workaroundArgument;

+ (BOOL)verifyNilSubject;
+ (BOOL)verifyNonNilSubject;

@end
