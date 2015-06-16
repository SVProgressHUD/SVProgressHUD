//
//  StringPrefixMatcher.h
//  Kiwi
//
//  Created by Luke Redpath on 17/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWStringPrefixMatcher : NSObject

+ (id)matcherWithPrefix:(NSString *)aPrefix;
- (id)initWithPrefix:(NSString *)aPrefix;

@end

#define hasPrefix(prefix) [KWStringPrefixMatcher matcherWithPrefix:prefix]
