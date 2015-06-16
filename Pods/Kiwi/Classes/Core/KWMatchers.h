//
//  KWMatchers.h
//  Kiwi
//
//  Created by Luke Redpath on 17/06/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KWUserDefinedMatcherBuilder;

typedef void (^KWMatchersBuildingBlock)(KWUserDefinedMatcherBuilder *matcherBuilder);

@class KWUserDefinedMatcher;

@interface KWMatchers : NSObject

+ (id)matchers;

#pragma mark - Defining Matchers

+ (void)defineMatcher:(NSString *)selectorString as:(KWMatchersBuildingBlock)block;
- (void)defineMatcher:(NSString *)selectorString as:(KWMatchersBuildingBlock)block;
- (void)addUserDefinedMatcherBuilder:(KWUserDefinedMatcherBuilder *)builder;

#pragma mark - Building Matchers

- (KWUserDefinedMatcher *)matcherForSelector:(SEL)selector subject:(id)subject;
@end

void KWDefineMatchers(NSString *selectorString, KWMatchersBuildingBlock block);
