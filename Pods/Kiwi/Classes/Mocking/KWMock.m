//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWMock.h"
#import <objc/runtime.h>
#import "KWFormatter.h"
#import "KWMessagePattern.h"
#import "KWMessageSpying.h"
#import "KWStringUtilities.h"
#import "KWStub.h"
#import "KWWorkarounds.h"
#import "NSInvocation+KiwiAdditions.h"
#import "KWCaptureSpy.h"

static NSString * const ExpectOrStubTagKey = @"ExpectOrStubTagKey";
static NSString * const StubTag = @"StubTag";
static NSString * const ExpectTag = @"ExpectTag";
static NSString * const StubValueKey = @"StubValueKey";
static NSString * const StubSecondValueKey = @"StubSecondValueKey";
static NSString * const ChangeStubValueAfterTimesKey = @"ChangeStubValueAfterTimesKey";

@interface KWMock()

@property (nonatomic, readonly) NSMutableArray *stubs;
@property (nonatomic, readonly) NSMutableArray *expectedMessagePatterns;
@property (nonatomic, readonly) NSMapTable *messageSpies;

@end

@implementation KWMock

#pragma mark - Initializing

- (id)init {
    // May already have been initialized since stubbing -init is allowed!
    if (self.stubs != nil) {
        KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
        [self expectMessagePattern:messagePattern];
        NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];

        if ([self processReceivedInvocation:invocation]) {
            __unsafe_unretained id result = nil;
            [invocation getReturnValue:&result];
            return result;
        } else {
            return self;
        }
    }

    return [self initAsNullMock:NO withName:nil forClass:nil protocol:nil];
}

- (id)initForClass:(Class)aClass {
    return [self initAsNullMock:NO withName:nil forClass:aClass protocol:nil];
}

- (id)initForProtocol:(Protocol *)aProtocol {
    return [self initAsNullMock:NO withName:nil forClass:nil protocol:aProtocol];
}

- (id)initWithName:(NSString *)aName forClass:(Class)aClass {
    return [self initAsNullMock:NO withName:aName forClass:aClass protocol:nil];
}

- (id)initWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol {
    return [self initAsNullMock:NO withName:aName forClass:nil protocol:aProtocol];
}

- (id)initAsNullMockForClass:(Class)aClass {
    return [self initAsNullMock:YES withName:nil forClass:aClass protocol:nil];
}

- (id)initAsNullMockForProtocol:(Protocol *)aProtocol {
    return [self initAsNullMock:YES withName:nil forClass:nil protocol:aProtocol];
}

- (id)initAsNullMockWithName:(NSString *)aName forClass:(Class)aClass {
    return [self initAsNullMock:YES withName:aName forClass:aClass protocol:nil];
}

- (id)initAsNullMockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol {
    return [self initAsNullMock:YES withName:aName forClass:nil protocol:aProtocol];
}

- (id)initAsNullMock:(BOOL)nullMockFlag withName:(NSString *)aName forClass:(Class)aClass protocol:(Protocol *)aProtocol {
    self = [super init];
    if (self) {
        _isNullMock = nullMockFlag;
        _mockName = [aName copy];
        _mockedClass = aClass;
        _mockedProtocol = aProtocol;
        _stubs = [[NSMutableArray alloc] init];
        _expectedMessagePatterns = [[NSMutableArray alloc] init];
        _messageSpies = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    }

    return self;
}

- (id)initAsPartialMockForObject:(id)object {
    return [self initAsPartialMockWithName:nil forObject:object];
}

- (id)initAsPartialMockWithName:(NSString *)aName forObject:(id)object {
    self = [self initAsNullMock:YES withName:aName forClass:[object class] protocol:nil];
    if (self) {
        _isPartialMock = YES;
        _mockedObject = object;
    }
    return self;
}

+ (id)mockForClass:(Class)aClass {
    return [[self alloc] initForClass:aClass];
}

+ (id)mockForProtocol:(Protocol *)aProtocol {
    return [[self alloc] initForProtocol:aProtocol];
}

+ (id)mockWithName:(NSString *)aName forClass:(Class)aClass {
    return [[self alloc] initWithName:aName forClass:aClass];
}

+ (id)mockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol {
    return [[self alloc] initWithName:aName forProtocol:aProtocol];
}

+ (id)nullMockForClass:(Class)aClass {
    return [[self alloc] initAsNullMockForClass:aClass];
}

+ (id)nullMockForProtocol:(Protocol *)aProtocol {
    return [[self alloc] initAsNullMockForProtocol:aProtocol];
}

+ (id)nullMockWithName:(NSString *)aName forClass:(Class)aClass {
    return [[self alloc] initAsNullMockWithName:aName forClass:aClass];
}

+ (id)nullMockWithName:(NSString *)aName forProtocol:(Protocol *)aProtocol {
    return [[self alloc] initAsNullMockWithName:aName forProtocol:aProtocol];
}

+ (id)partialMockWithName:(NSString *)aName forObject:(id)object {
    return [[self alloc] initAsPartialMockWithName:aName forObject:object];
}

+ (id)partialMockForObject:(id)object {
    return [[self alloc] initAsPartialMockForObject:object];
}

#pragma mark - Getting Transitive Closure For Mocked Protocols

- (NSSet *)mockedProtocolTransitiveClosureSet {
    if (self.mockedProtocol == nil)
        return nil;

    NSMutableSet *protocolSet = [NSMutableSet set];
    NSMutableArray *protocolQueue = [NSMutableArray array];
    [protocolQueue addObject:self.mockedProtocol];

    do {
        Protocol *protocol = [protocolQueue lastObject];
        [protocolSet addObject:protocol];
        [protocolQueue removeLastObject];

        unsigned int count = 0;
        Protocol *__unsafe_unretained*protocols = protocol_copyProtocolList(protocol, &count);

        if (count == 0)
            continue;

        for (unsigned int i = 0; i < count; ++i)
            [protocolQueue addObject:protocols[i]];

        free(protocols);
    } while ([protocolQueue count] != 0);

    return protocolSet;
}

#pragma mark - Stubbing Methods

- (void)removeStubWithMessagePattern:(KWMessagePattern *)messagePattern {
    KWStub *stub = [self currentStubWithMessagePattern:messagePattern];
    if (stub) {
        [self.stubs removeObject:stub];
    }
}

- (KWStub *)currentStubWithMessagePattern:(KWMessagePattern *)messagePattern {
    NSUInteger stubCount = [self.stubs count];
    
    for (NSUInteger i = 0; i < stubCount; ++i) {
        KWStub *stub = (self.stubs)[i];
        
        if ([stub.messagePattern isEqualToMessagePattern:messagePattern]) {
            return stub;
        }
    }
    return nil;
}

- (void)stub:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self stubMessagePattern:messagePattern andReturn:nil];
}

- (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *params))block {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self stubMessagePattern:messagePattern withBlock:block];
}

- (void)stub:(SEL)aSelector withArguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [self stubMessagePattern:messagePattern andReturn:nil];
}

- (void)stub:(SEL)aSelector andReturn:(id)aValue {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self stubMessagePattern:messagePattern andReturn:aValue];
}

- (void)stub:(SEL)aSelector andReturn:(id)aValue withArguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [self stubMessagePattern:messagePattern andReturn:aValue];
}

- (id)stub {
    NSDictionary *userInfo = @{ExpectOrStubTagKey: StubTag};
    return [KWInvocationCapturer invocationCapturerWithDelegate:self userInfo:userInfo];
}

- (id)stubAndReturn:(id)aValue {
    NSDictionary *userInfo = @{ExpectOrStubTagKey: StubTag,
                                                                        StubValueKey: aValue};
    return [KWInvocationCapturer invocationCapturerWithDelegate:self userInfo:userInfo];
}

- (id)stubAndReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue {
    NSDictionary *userInfo = @{ExpectOrStubTagKey: StubTag, StubValueKey: aValue, ChangeStubValueAfterTimesKey: times, StubSecondValueKey: aSecondValue};
    return [KWInvocationCapturer invocationCapturerWithDelegate:self userInfo:userInfo];
}

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue {
    [self stubMessagePattern:aMessagePattern andReturn:aValue overrideExisting:YES];
}

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue overrideExisting:(BOOL)overrideExisting {
    [self expectMessagePattern:aMessagePattern];
    KWStub *existingStub = [self currentStubWithMessagePattern:aMessagePattern];
    if (existingStub) {
        if (overrideExisting) {
            [self.stubs removeObject:existingStub];
        } else {
            return;
        }
    }
    KWStub *stub = [KWStub stubWithMessagePattern:aMessagePattern value:aValue];
    [self.stubs addObject:stub];
}

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern withBlock:(id (^)(NSArray *params))block {
    [self expectMessagePattern:aMessagePattern];
    [self removeStubWithMessagePattern:aMessagePattern];
    KWStub *stub = [KWStub stubWithMessagePattern:aMessagePattern block:block];
    [self.stubs addObject:stub];
}

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue times:(id)times afterThatReturn:(id)aSecondValue {   
    [self expectMessagePattern:aMessagePattern];
    [self removeStubWithMessagePattern:aMessagePattern];
    KWStub *stub = [KWStub stubWithMessagePattern:aMessagePattern value:aValue times:times afterThatReturn:aSecondValue];
    [self.stubs addObject:stub];
}

- (void)clearStubs {
    [self.stubs removeAllObjects];
}

#pragma mark - Spying on Messages

- (void)addMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern {
    [self expectMessagePattern:aMessagePattern];
    NSMutableArray *messagePatternSpies = [self.messageSpies objectForKey:aMessagePattern];

    if (messagePatternSpies == nil) {
        messagePatternSpies = [[NSMutableArray alloc] init];
        [self.messageSpies setObject:messagePatternSpies forKey:aMessagePattern];
    }

    if (![messagePatternSpies containsObject:aSpy])
        [messagePatternSpies addObject:aSpy];
}

- (void)removeMessageSpy:(id<KWMessageSpying>)aSpy forMessagePattern:(KWMessagePattern *)aMessagePattern {
    NSMutableArray *messagePatternSpies = [self.messageSpies objectForKey:aMessagePattern];
    [messagePatternSpies removeObject:aSpy];
}

#pragma mark - Expecting Message Patterns

- (void)expect:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self expectMessagePattern:messagePattern];
}

- (void)expect:(SEL)aSelector withArguments:(id)firstArgument, ... {
    va_list argumentList;
    va_start(argumentList, firstArgument);
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
    [self expectMessagePattern:messagePattern];
}

- (id)expect {
    NSDictionary *userInfo = @{ExpectOrStubTagKey: ExpectTag};
    return [KWInvocationCapturer invocationCapturerWithDelegate:self userInfo:userInfo];
}

- (void)expectMessagePattern:(KWMessagePattern *)aMessagePattern {
    if (![self.expectedMessagePatterns containsObject:aMessagePattern])
        [self.expectedMessagePatterns addObject:aMessagePattern];
}

#pragma mark - Capturing Invocations

- (NSMethodSignature *)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer methodSignatureForSelector:(SEL)aSelector {
    return [self methodSignatureForSelector:aSelector];
}

- (void)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer didCaptureInvocation:(NSInvocation *)anInvocation {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternFromInvocation:anInvocation];
    NSString *tag = (anInvocationCapturer.userInfo)[ExpectOrStubTagKey];
    if ([tag isEqualToString:StubTag]) {
        id value = (anInvocationCapturer.userInfo)[StubValueKey];
        if (!(anInvocationCapturer.userInfo)[StubSecondValueKey]) {
            [self stubMessagePattern:messagePattern andReturn:value];
        } else {
            id times = (anInvocationCapturer.userInfo)[ChangeStubValueAfterTimesKey];
            id secondValue = (anInvocationCapturer.userInfo)[StubSecondValueKey];
            [self stubMessagePattern:messagePattern andReturn:value times:times afterThatReturn:secondValue];
        }
    } else {
        [self expectMessagePattern:messagePattern];
    }
}


#pragma mark - Handling Invocations

- (NSString *)namePhrase {
    if (self.mockName == nil)
        return @"mock";
    else
        return [NSString stringWithFormat:@"mock \"%@\"", self.mockName];
}

- (BOOL)processReceivedInvocation:(NSInvocation *)invocation {
    for (KWMessagePattern *messagePattern in self.messageSpies) {
        if ([messagePattern matchesInvocation:invocation]) {
            NSArray *spies = [self.messageSpies objectForKey:messagePattern];

              for (id<KWMessageSpying> spy in spies) {
                [spy object:self didReceiveInvocation:invocation];
              }
        }
    }

    for (KWStub *stub in self.stubs) {
        if ([stub processInvocation:invocation])
            return YES;
    }

    return NO;
}

- (NSMethodSignature *)mockedProtocolMethodSignatureForSelector:(SEL)aSelector {
    NSSet *protocols = [self mockedProtocolTransitiveClosureSet];

    for (Protocol *protocol in protocols) {
        struct objc_method_description description = protocol_getMethodDescription(protocol, aSelector, NO, YES);

        if (description.types == nil)
            description = protocol_getMethodDescription(protocol, aSelector, YES, YES);

        if (description.types != nil)
            return [NSMethodSignature signatureWithObjCTypes:description.types];
    }

    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *methodSignature = [self.mockedClass instanceMethodSignatureForSelector:aSelector];

    if (methodSignature != nil)
        return methodSignature;

    methodSignature = [self mockedProtocolMethodSignatureForSelector:aSelector];

    if (methodSignature != nil)
        return methodSignature;

    NSString *encoding = KWEncodingForDefaultMethod();
    return [NSMethodSignature signatureWithObjCTypes:[encoding UTF8String]];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    @try {
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

    if ([self processReceivedInvocation:anInvocation])
        return;

    if (self.isPartialMock)
        [anInvocation invokeWithTarget:self.mockedObject];

    if (self.isNullMock)
        return;

    for (KWMessagePattern *expectedMessagePattern in self.expectedMessagePatterns) {
        if ([expectedMessagePattern matchesInvocation:anInvocation])
            return;
    }

    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternFromInvocation:anInvocation];
    [NSException raise:@"KWMockException" format:@"%@ received unexpected message -%@",
                                                 [self namePhrase],
                                                 [messagePattern stringValue]];

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    } @catch (NSException *exception) {
        KWSetExceptionFromAcrossInvocationBoundary(exception);
    }
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
}

#pragma mark - Testing Objects

- (BOOL)mockedClassHasAncestorClass:(Class)aClass {
    Class currentClass = self.mockedClass;

    while (currentClass != nil) {
        if (currentClass == aClass)
            return YES;

        currentClass = [currentClass superclass];
    }

    return NO;
}

- (BOOL)mockedClassRespondsToSelector:(SEL)aSelector {
    return [self.mockedClass instancesRespondToSelector:aSelector];
}

- (BOOL)mockedClassConformsToProtocol:(Protocol *)aProtocol {
    return [self.mockedClass conformsToProtocol:aProtocol];
}

- (BOOL)mockedProtocolRespondsToSelector:(SEL)aSelector {
    NSSet *protocols = [self mockedProtocolTransitiveClosureSet];

    for (Protocol *protocol in protocols) {
        struct objc_method_description description = protocol_getMethodDescription(protocol, aSelector, NO, YES);

        if (description.types == nil)
            description = protocol_getMethodDescription(protocol, aSelector, YES, YES);

        if (description.types != nil)
            return YES;
    }

    return NO;
}

- (BOOL)mockedProtocolConformsToProtocol:(Protocol *)aProtocol {
    if (self.mockedProtocol == nil)
        return NO;

    return protocol_isEqual(self.mockedProtocol, aProtocol) || protocol_conformsToProtocol(self.mockedProtocol, aProtocol);
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [self mockedClassHasAncestorClass:aClass] || [super isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return self.mockedClass == aClass || [super isMemberOfClass:aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self mockedClassRespondsToSelector:aSelector] ||
           [self mockedProtocolRespondsToSelector:aSelector] ||
           [super respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self mockedClassConformsToProtocol:aProtocol] ||
           [self mockedProtocolConformsToProtocol:aProtocol] ||
           [super conformsToProtocol:aProtocol];
}

#pragma mark - Whitelisted NSObject Methods

- (BOOL)isEqual:(id)anObject {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd messageArguments:&anObject];

    if ([self processReceivedInvocation:invocation]) {
        BOOL result = NO;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return [super isEqual:anObject];
    }
}

- (NSUInteger)hash {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];

    if ([self processReceivedInvocation:invocation]) {
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return [super hash];
    }
}

- (NSString *)description {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];

    if ([self processReceivedInvocation:invocation]) {
        __unsafe_unretained NSString *result = nil;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return [super description];
    }
}

- (id)copy {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];

    if ([self processReceivedInvocation:invocation]) {
        __unsafe_unretained id result = nil;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return [super copy];
    }
}

- (id)mutableCopy {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];

    if ([self processReceivedInvocation:invocation]) {
        __unsafe_unretained id result = nil;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return [super mutableCopy];
    }
}

#pragma mark -
#pragma mark Key-Value Coding Support

static id valueForKeyImplementation(id self, SEL _cmd, id key) {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd messageArguments:&key];
    
    if ([self processReceivedInvocation:invocation]) {
        __unsafe_unretained id result = nil;
        [invocation getReturnValue:&result];
        return result;
    } else {
        return nil;
    }
}

- (id)valueForKey:(NSString *)key {
    return valueForKeyImplementation(self, _cmd, key);
}

- (id)valueForKeyPath:(NSString *)keyPath {
    return valueForKeyImplementation(self, _cmd, keyPath);
}

static void setValueForKeyImplementation(id self, SEL _cmd, id a, id b) {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:_cmd];
    [self expectMessagePattern:messagePattern];
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd messageArguments:&a, &b];
    
    [self processReceivedInvocation:invocation];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    setValueForKeyImplementation(self, _cmd, value, key);
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    setValueForKeyImplementation(self, _cmd, value, keyPath);
}

@end
