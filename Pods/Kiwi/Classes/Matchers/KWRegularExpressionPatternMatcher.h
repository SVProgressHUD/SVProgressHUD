//
//  KWRegularExpressionPatternMatcher.h
//  Kiwi
//
//  Created by Kristopher Johnson on 4/11/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWRegularExpressionPatternMatcher : KWMatcher

- (void)matchPattern:(NSString *)pattern;

- (void)matchPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

@end
