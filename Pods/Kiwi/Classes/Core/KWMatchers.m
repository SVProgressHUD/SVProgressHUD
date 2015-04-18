//
//  KWMatchers.m
//  Kiwi
//
//  Created by Luke Redpath on 17/06/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import "KWMatchers.h"
#import "KWUserDefinedMatcher.h"

@interface KWMatchers() {
    NSMutableDictionary *userDefinedMatchers;
}
@end

@implementation KWMatchers

#pragma mark - Singleton implementation

static id sharedMatchers = nil;

+ (void)initialize {
    if (self == [KWMatchers class]) {
        sharedMatchers = [[self alloc] init];
    }
}

+ (id)matchers {
    return sharedMatchers;
}

- (id)init {
    self = [super init];
    if (self) {
        userDefinedMatchers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Defining Matchers

+ (void)defineMatcher:(NSString *)selectorString as:(KWMatchersBuildingBlock)block {
    [[self matchers] defineMatcher:selectorString as:block];
}

- (void)defineMatcher:(NSString *)selectorString as:(KWMatchersBuildingBlock)block {
    KWUserDefinedMatcherBuilder *builder = [KWUserDefinedMatcherBuilder builderForSelector:NSSelectorFromString(selectorString)];
    block(builder);
    userDefinedMatchers[builder.key] = builder;
}

- (void)addUserDefinedMatcherBuilder:(KWUserDefinedMatcherBuilder *)builder {
    userDefinedMatchers[builder.key] = builder;
}

#pragma mark - Building Matchers

- (KWUserDefinedMatcher *)matcherForSelector:(SEL)selector subject:(id)subject {
    KWUserDefinedMatcherBuilder *builder = userDefinedMatchers[NSStringFromSelector(selector)];

    if (builder == nil)
        return nil;

    return [builder buildMatcherWithSubject:subject];
}


@end

void KWDefineMatchers(NSString *selectorString, KWMatchersBuildingBlock block)
{
    [KWMatchers defineMatcher:selectorString as:block];
}

