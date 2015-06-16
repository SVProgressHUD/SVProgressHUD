//
//  KWHaveValueMatcher.h
//  Kiwi
//
//  Created by Luke Redpath on 24/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWMatcher.h"

@interface KWHaveValueMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)haveValue:(id)value forKey:(NSString *)key;
- (void)haveValue:(id)value forKeyPath:(NSString *)keyPath;
- (void)haveValueForKey:(NSString *)key;
- (void)haveValueForKeyPath:(NSString *)keyPath;

@end
