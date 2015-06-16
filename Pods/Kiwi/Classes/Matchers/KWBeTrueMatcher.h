//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWBeTrueMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)beTrue;
- (void)beFalse;
- (void)beYes;
- (void)beNo;

@end
