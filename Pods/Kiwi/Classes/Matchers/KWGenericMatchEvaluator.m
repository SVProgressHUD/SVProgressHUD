//
//  KWGenericMatcher.m
//  Kiwi
//
//  Created by Allen Ding on 1/31/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KWGenericMatchEvaluator.h"
#import "KWStringUtilities.h"
#import "KWObjCUtilities.h"
#import <objc/runtime.h>
#import "KWGenericMatcher.h"

@implementation KWGenericMatchEvaluator

// Returns true only if the object has a method with the signature "- (BOOL)matches:(id)object"
+ (BOOL)isGenericMatcher:(id)object {
    Class theClass = object_getClass(object);

    if (theClass == NULL) {
        return NO;
    }
    Method method = class_getInstanceMethod(theClass, @selector(matches:));

    if (method == NULL) {
        return NO;
    }

    const char *cEncoding = method_getTypeEncoding(method);

    if (cEncoding == NULL) {
        return NO;
    }

    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:cEncoding];

    if (!KWObjCTypeEqualToObjCType(@encode(BOOL), [signature methodReturnType])) {
        return NO;
    }

    if ([signature numberOfArguments] != 3) {
        return NO;
    }

    if (!KWObjCTypeEqualToObjCType(@encode(id), [signature getArgumentTypeAtIndex:2])) {
        return NO;
    }

    return YES;
}

+ (BOOL)genericMatcher:(id)matcher matches:(id)object {
    NSString *targetEncoding = KWEncodingWithObjCTypes(@encode(BOOL), @encode(id), @encode(SEL), @encode(id), nil);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:[targetEncoding UTF8String]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:@selector(matches:)];
    [invocation setArgument:&object atIndex:2];
    [invocation invokeWithTarget:matcher];
    BOOL result = NO;
    [invocation getReturnValue:&result];
    return result;
}

@end
