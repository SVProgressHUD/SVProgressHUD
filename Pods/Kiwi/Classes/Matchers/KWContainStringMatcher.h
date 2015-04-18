//
//  KWContainStringMatcher.h
//  Kiwi
//
//  Created by Kristopher Johnson on 4/28/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

// Kiwi matcher for determining whether a string contains an expected substring
//
// Examples:
//
//     [[@"Hello, world!" should] containString:@"world"];
//     [[@"Hello, world!" shouldNot] containString:@"xyzzy"];
//
//     [[@"Hello, world!" should] containString:@"WORLD"
//                                      options:NSCaseInsensitiveSearch];
//
//     [[@"Hello, world!" should] startWithString:@"Hello,"];
//     [[@"Hello, world!" should] endWithString:@"world!"];

@interface KWContainStringMatcher : KWMatcher

// Match if subject contains specified substring
- (void)containString:(NSString *)string;

// Match if subject contains specified substring, using specified comparison options
- (void)containString:(NSString *)string options:(NSStringCompareOptions)options;

// Match if subject starts with the specified prefix
- (void)startWithString:(NSString *)prefix;

// Match if subject ends with the specified prefix
- (void)endWithString:(NSString *)suffix;

@end
