//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWInvocationCapturer.h"

@class KWMessagePattern;
@class KWCaptureSpy;

@protocol KWMessageSpying;
@protocol KWVerifying;

@interface KWMock : NSObject

#pragma mark - Initializing

- (id)initForClass:(Class)aClass;
- (id)initForProtocol:(Protocol *)aProtocol;
- (id)initWithName:(NSString *)aName forClass:(Class)aClass;
- (id)initWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol;

- (id)initAsNullMockForClass:(Class)aClass;
- (id)initAsNullMockForProtocol:(Protocol *)aProtocol;
- (id)initAsNullMockWithName:(NSString *)aName forClass:(Class)aClass;
- (id)initAsNullMockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol;

- (id)initAsPartialMockForObject:(id)object;
- (id)initAsPartialMockWithName:(NSString *)aName forObject:(id)object;

+ (id)mockForClass:(Class)aClass;
+ (id)mockForProtocol:(Protocol *)aProtocol;
+ (id)mockWithName:(NSString *)aName forClass:(Class)aClass;
+ (id)mockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol;

+ (id)nullMockForClass:(Class)aClass;
+ (id)nullMockForProtocol:(Protocol *)aProtocol;
+ (id)nullMockWithName:(NSString *)aName forClass:(Class)aClass ;
+ (id)nullMockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol;

+ (id)partialMockForObject:(id)object;
+ (id)partialMockWithName:(NSString *)aName forObject:(id)object;

#pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL isNullMock;
@property (nonatomic, assign, readonly) BOOL isPartialMock;
@property (nonatomic, copy, readonly) NSString *mockName;
@property (nonatomic, assign, readonly) Class mockedClass;
@property (nonatomic, strong, readonly) id mockedObject;
@property (nonatomic, assign, readonly) Protocol *mockedProtocol;

#pragma mark - Stubbing Methods

- (void)stub:(SEL)aSelector;
- (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *params))block;
- (void)stub:(SEL)aSelector withArguments:(id)firstArgument, ...;
- (void)stub:(SEL)aSelector andReturn:(id)aValue;
- (void)stub:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ...;

- (id)stub;
- (id)stubAndReturn:(id)aValue;
- (id)stubAndReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue;

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue;
- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue;

- (void)clearStubs;

#pragma mark - Spying on Messages

- (void)addMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;
- (void)removeMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern;


#pragma mark - Expecting Messages

- (void)expect:(SEL)aSelector;
- (void)expect:(SEL)aSelector withArguments:(id)firstArgument, ...;

- (id)expect;

- (void)expectMessagePattern:(KWMessagePattern *)aMessagePattern;

@end
