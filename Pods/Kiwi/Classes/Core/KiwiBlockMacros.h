//
//  KiwiBlockMacros.h
//  Kiwi
//
//  Created by Luke Redpath on 11/07/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

// user defined matchers
#define registerMatcher(name) \
\
@interface NSObject (KWUserDefinedMatchersDefinitions) \
- (void)name; \
@end \

#define defineMatcher(...) KWDefineMatchers(__VA_ARGS__)
