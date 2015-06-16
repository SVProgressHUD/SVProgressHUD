//
//  KWChangeMatcher.h
//  Kiwi
//
//  Copyright (c) 2013 Eloy Durán <eloy.de.enige@gmail.com>.
//  All rights reserved.
//

#import "KWMatcher.h"

typedef NSInteger (^KWChangeMatcherCountBlock)();

@interface KWChangeMatcher : KWMatcher

// Expect _any_ change.
- (void)change:(KWChangeMatcherCountBlock)countBlock;

// Expect changes by a specific amount.
- (void)change:(KWChangeMatcherCountBlock)countBlock by:(NSInteger)expectedDifference;

@end
