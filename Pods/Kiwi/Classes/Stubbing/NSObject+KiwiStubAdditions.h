//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@class KWCaptureSpy;
@class KWMessagePattern;

@protocol KWMessageSpying;

@protocol KiwiStubAdditions <NSObject>

#pragma mark - Stubbing Methods

- (void)stub:(SEL)aSelector;
- (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *params))block;
- (void)stub:(SEL)aSelector withArguments:(id)firstArgument, ...;
- (void)stub:(SEL)aSelector andReturn:(id)aValue;
- (void)stub:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ...;
- (void)stub:(SEL)aSelector andReturn:(id)aValue times:(NSNumber *)times afterThatReturn:(id)aSecondValue;

+ (void)stub:(SEL)aSelector;
+ (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *params))block;
+ (void)stub:(SEL)aSelector withArguments:(id)firstArgument, ...;
+ (void)stub:(SEL)aSelector andReturn:(id)aValue;
+ (void)stub:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ...;
+ (void)stub:(SEL)aSelector andReturn:(id)aValue times:(NSNumber *)times afterThatReturn:(id)aSecondValue;

- (id)stub DEPRECATED_ATTRIBUTE;
- (id)stubAndReturn:(id)aValue DEPRECATED_ATTRIBUTE;
- (id)stubAndReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue DEPRECATED_ATTRIBUTE;

// These methods will become private
- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue;
- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue overrideExisting:(BOOL)overrideExisting;
- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue;
- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern withBlock:(id (^)(NSArray *params))block;

// These methods will become private
+ (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue;
+ (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue;
+ (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern withBlock:(id (^)(NSArray *params))block;

- (void)clearStubs;

#pragma mark - Spying on Messages

- (void)addMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;
- (void)removeMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;
- (KWCaptureSpy *)captureArgument:(SEL)selector atIndex:(NSUInteger)index;

+ (void)addMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;
+ (void)removeMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;
+ (KWCaptureSpy *)captureArgument:(SEL)selector atIndex:(NSUInteger)index;

@end

@interface NSObject(KiwiStubAdditions) <KiwiStubAdditions>

@end
