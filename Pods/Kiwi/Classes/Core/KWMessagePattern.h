//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface KWMessagePattern : NSObject

#pragma mark - Initializing

- (id)initWithSelector:(SEL)aSelector;
- (id)initWithSelector:(SEL)aSelector argumentFilters:(NSArray *)anArray;
- (id)initWithSelector:(SEL)aSelector firstArgumentFilter:(id)firstArgumentFilter argumentList:(va_list)argumentList;

+ (id)messagePatternWithSelector:(SEL)aSelector;
+ (id)messagePatternWithSelector:(SEL)aSelector argumentFilters:(NSArray *)anArray;
+ (id)messagePatternWithSelector:(SEL)aSelector firstArgumentFilter:(id)firstArgumentFilter argumentList:(va_list)argumentList;

+ (id)messagePatternFromInvocation:(NSInvocation *)anInvocation;

#pragma mark - Properties

@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) NSArray *argumentFilters;

#pragma mark - Matching Invocations

- (BOOL)matchesInvocation:(NSInvocation *)anInvocation;

#pragma mark - Comparing Message Patterns

- (BOOL)isEqualToMessagePattern:(KWMessagePattern *)aMessagePattern;

#pragma mark - Retrieving String Representations

- (NSString *)stringValue;

@end
