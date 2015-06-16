//
//  KWStringContainsMatcher.h
//  Kiwi
//
//  Created by Stewart Gleadow on 7/06/12.
//  Copyright (c) 2012 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWGenericMatcher.h"

@interface KWStringContainsMatcher : NSObject <KWGenericMatching>

+ (id)matcherWithSubstring:(NSString *)aSubstring DEPRECATED_ATTRIBUTE;
- (id)initWithSubstring:(NSString *)aSubstring DEPRECATED_ATTRIBUTE;

@end

#define hasSubstring(substring) [KWStringContainsMatcher matcherWithSubstring:substring]
