//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWInvocationCapturer.h"
#import "KWWorkarounds.h"
#import "NSInvocation+KiwiAdditions.h"

@implementation KWInvocationCapturer

#pragma mark - Initializing

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate userInfo:nil];
}

- (id)initWithDelegate:(id)aDelegate userInfo:(NSDictionary *)aUserInfo {
    delegate = aDelegate;
    userInfo = aUserInfo;
    return self;
}

+ (id)invocationCapturerWithDelegate:(id)aDelegate {
    return [self invocationCapturerWithDelegate:aDelegate userInfo:nil];
}

+ (id)invocationCapturerWithDelegate:(id)aDelegate userInfo:(NSDictionary *)aUserInfo {
    return [[self alloc] initWithDelegate:aDelegate userInfo:aUserInfo];
}


#pragma mark - Properties

@synthesize delegate;
@synthesize userInfo;

#pragma mark - Capturing Invocations

- (void)KW_captureInvocation:(NSInvocation *)anInvocation {
    [self.delegate invocationCapturer:self didCaptureInvocation:anInvocation];
}

#pragma mark - Handling Invocations

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.delegate invocationCapturer:self methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    @try {
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

    [self KW_captureInvocation:anInvocation];

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    } @catch (NSException *exception) {
        KWSetExceptionFromAcrossInvocationBoundary(exception);
    }
#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
}

#pragma mark - Whitelisted NSObject Methods

// The return values from these methods should never be needed, so just call
// the super implementation after capturing the invocation.

- (BOOL)isEqual:(id)anObject {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd messageArguments:&anObject];
    [self KW_captureInvocation:invocation];
    return [super isEqual:anObject];
}

- (NSUInteger)hash {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];
    [self KW_captureInvocation:invocation];
    return [super hash];
}

- (NSString *)description {
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:_cmd];
    [self KW_captureInvocation:invocation];
    return [super description];
}

@end
