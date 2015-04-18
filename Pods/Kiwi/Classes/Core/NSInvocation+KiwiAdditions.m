//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "NSInvocation+KiwiAdditions.h"
#import "KWFormatter.h"
#import "KWObjCUtilities.h"
#import "NSMethodSignature+KiwiAdditions.h"

@implementation NSInvocation(KiwiAdditions)

#pragma mark - Creating NSInvocation Objects

+ (NSInvocation *)invocationWithTarget:(id)anObject selector:(SEL)aSelector {
    return [self invocationWithTarget:anObject selector:aSelector messageArguments:nil];
}

+ (NSInvocation *)invocationWithTarget:(id)anObject selector:(SEL)aSelector messageArguments:(const void *)firstBytes, ... {
    if (anObject == nil) {
        [NSException raise:NSInvalidArgumentException format:@"%@ - target must not be nil",
                                                             NSStringFromSelector(_cmd)];
    }

    NSMethodSignature *signature = [anObject methodSignatureForSelector:aSelector];

    if (signature == nil) {
        [NSException raise:NSInvalidArgumentException format:@"%@ - target returned nil for -methodSignatureForSelector",
                                                             NSStringFromSelector(_cmd)];
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:anObject];
    [invocation setSelector:aSelector];
    NSUInteger numberOfMessageArguments = [signature numberOfMessageArguments];

    if (numberOfMessageArguments == 0)
        return invocation;

    va_list argumentList;
    va_start(argumentList, firstBytes);
    const void *bytes = firstBytes;

    for (NSUInteger i = 0; i < numberOfMessageArguments && bytes != nil; ++i) {
        [invocation setMessageArgument:bytes atIndex:i];
        bytes = va_arg(argumentList, const void *);
    }

    va_end(argumentList);
    return invocation;
}

#pragma mark - Accessing Message Arguments

- (NSData *)messageArgumentDataAtIndex:(NSUInteger)anIndex {
    NSUInteger length =  KWObjCTypeLength([[self methodSignature] messageArgumentTypeAtIndex:anIndex]);
    void *buffer = malloc(length);
    [self getMessageArgument:buffer atIndex:anIndex];
    // NSData takes over ownership of buffer
    NSData* data = [NSData dataWithBytesNoCopy:buffer length:length];
    return data;
}

- (void)getMessageArgument:(void *)buffer atIndex:(NSUInteger)anIndex {
    [self getArgument:buffer atIndex:anIndex + 2];
}

- (void)setMessageArgument:(const void *)bytes atIndex:(NSUInteger)anIndex {
    [self setArgument:(void *)bytes atIndex:anIndex + 2];
}

- (void)setMessageArguments:(const void *)firstBytes, ... {
    NSUInteger numberOfMessageArguments = [[self methodSignature] numberOfMessageArguments];

    if (numberOfMessageArguments == 0)
        return;

    va_list argumentList;
    va_start(argumentList, firstBytes);
    const void *bytes = firstBytes;

    for (NSUInteger i = 0; i < numberOfMessageArguments && bytes != nil; ++i) {
        [self setMessageArgument:bytes atIndex:i];
        bytes = va_arg(argumentList, const void *);
    }

    va_end(argumentList);
}

@end
