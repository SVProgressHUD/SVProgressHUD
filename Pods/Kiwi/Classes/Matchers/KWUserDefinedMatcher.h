//
//  KWUserDefinedMatcher.h
//  Kiwi
//
//  Created by Luke Redpath on 16/06/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWMatcher.h"

typedef BOOL (^KWUserDefinedMatcherBlock)();

@interface KWUserDefinedMatcher : KWMatcher

@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString *failureMessageForShould;
@property (nonatomic, copy) NSString *failureMessageForShouldNot;
@property (nonatomic, copy) KWUserDefinedMatcherBlock matcherBlock;
@property (nonatomic, copy) NSString *description;

+ (id)matcherWithSubject:(id)aSubject block:(KWUserDefinedMatcherBlock)aBlock;
- (id)initWithSubject:(id)aSubject block:(KWUserDefinedMatcherBlock)aBlock;
@end

#pragma mark -

typedef NSString * (^KWUserDefinedMatcherMessageBlock)(id);

@interface KWUserDefinedMatcherBuilder : NSObject
{
    KWUserDefinedMatcher *matcher;
    KWUserDefinedMatcherMessageBlock failureMessageForShouldBlock;
    KWUserDefinedMatcherMessageBlock failureMessageForShouldNotBlock;
    NSString *description;
}
@property (nonatomic, copy, readonly) NSString *key;

+ (id)builder;
+ (id)builderForSelector:(SEL)aSelector;
- (id)initWithSelector:(SEL)aSelector;

#pragma mark - Configuring The Matcher

- (void)match:(KWUserDefinedMatcherBlock)block;
- (void)failureMessageForShould:(KWUserDefinedMatcherMessageBlock)block;
- (void)failureMessageForShouldNot:(KWUserDefinedMatcherMessageBlock)block;
- (void)description:(NSString *)description;

#pragma mark - Buiding The Matcher

- (KWUserDefinedMatcher *)buildMatcherWithSubject:(id)subject;
@end
