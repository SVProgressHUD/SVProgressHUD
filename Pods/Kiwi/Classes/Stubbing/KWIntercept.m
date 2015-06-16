//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWIntercept.h"
#import "KWMessagePattern.h"
#import "KWMessageSpying.h"
#import "KWStub.h"

static const char * const KWInterceptClassSuffix = "_KWIntercept";

void KWObjectStubsInit(void);
void KWClearObjectStubs(id anObject);
void KWClearAllObjectStubs(void);
NSMutableArray *KWObjectStubsForObject(id anObject);
void KWObjectStubsSet(id anObject, NSMutableArray *stubs);

void KWMessageSpiesInit(void);
NSMapTable *KWMessageSpiesForObject(id anObject);
void KWClearMessageSpies(id anObject);
void KWMessageSpiesSet(id anObject, NSMapTable *spies);

Class KWRestoreOriginalClass(id anObject);
BOOL KWObjectClassRestored(id anObject);

typedef id (^KWInterceptedObjectBlock)(void);
// Use KWInterceptedObjectKey, instead of the object itself, when
// registering an object in a global map table, to prevent an infinite
// loop when the object is hashed.
KWInterceptedObjectBlock KWInterceptedObjectKey(id anObject);

#pragma mark - Intercept Enabled Method Implementations

void KWInterceptedForwardInvocation(id anObject, SEL aSelector, NSInvocation* anInvocation);
void KWInterceptedDealloc(id anObject, SEL aSelector);
Class KWInterceptedClass(id anObject, SEL aSelector);
Class KWInterceptedSuperclass(id anObject, SEL aSelector);

#pragma mark - Getting Forwarding Implementations

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

IMP KWRegularForwardingImplementation(void) {
    return class_getMethodImplementation([NSObject class], @selector(KWNonExistantSelector));
}

IMP KWStretForwardingImplementation(void) {
#ifndef __arm64__
    return class_getMethodImplementation_stret([NSObject class], @selector(KWNonExistantSelector));
#else
    return class_getMethodImplementation([NSObject class], @selector(KWNonExistantSelector));
#endif
}

#pragma clang diagnostic pop

IMP KWForwardingImplementationForMethodEncoding(const char* encoding) {
#if TARGET_CPU_ARM
    const NSUInteger stretLengthThreshold = 4;
#elif TARGET_CPU_X86
    const NSUInteger stretLengthThreshold = 8;
#else
    // TODO: This just makes an assumption right now. Expand to support all
    // official architectures correctly.
    const NSUInteger stretLengthThreshold = 8;
#endif // #if TARGET_CPU_ARM

    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:encoding];

    if (*[signature methodReturnType] == '{' && [signature methodReturnLength] > stretLengthThreshold) {
        NSLog(@"Warning: The Objective-C runtime appears to have bugs when forwarding messages with certain struct layouts as return types, so if a crash occurs this could be the culprit");
        return KWStretForwardingImplementation();
    } else {
        return KWRegularForwardingImplementation();
    }
}

#pragma mark - Getting Intercept Class Information

BOOL KWObjectIsClass(id anObject) {
    return class_isMetaClass(object_getClass(anObject));
}

BOOL KWClassIsInterceptClass(Class aClass) {
    const char *name = class_getName(aClass);
    char *result = strstr(name, KWInterceptClassSuffix);
    return result != nil;
}

int interceptCount = 0;

NSString *KWInterceptClassNameForClass(Class aClass) {
    const char *className = class_getName(aClass);
    interceptCount++;
    return [NSString stringWithFormat:@"%s%s%d", className, KWInterceptClassSuffix, interceptCount];
}

Class KWInterceptClassForCanonicalClass(Class canonicalClass) {
    NSString *interceptClassName = KWInterceptClassNameForClass(canonicalClass);
    Class interceptClass = NSClassFromString(interceptClassName);

    if (interceptClass != nil)
        return interceptClass;

    interceptClass = objc_allocateClassPair(canonicalClass, [interceptClassName UTF8String], 0);
    objc_registerClassPair(interceptClass);

    class_addMethod(interceptClass, @selector(forwardInvocation:), (IMP)KWInterceptedForwardInvocation, "v@:@");
    class_addMethod(interceptClass, @selector(class), (IMP)KWInterceptedClass, "#@:");
    //TODO: potentially get rid of this?
    class_addMethod(interceptClass, NSSelectorFromString(@"dealloc"), (IMP)KWInterceptedDealloc, "v@:");
    //
    class_addMethod(interceptClass, @selector(superclass), (IMP)KWInterceptedSuperclass, "#@:");

    Class interceptMetaClass = object_getClass(interceptClass);
    class_addMethod(interceptMetaClass, @selector(forwardInvocation:), (IMP)KWInterceptedForwardInvocation, "v@:@");

    return interceptClass;
}

Class KWRealClassForClass(Class aClass) {
    if (KWClassIsInterceptClass(aClass))
        return [aClass superclass];

    return aClass;
}

#pragma mark - Enabling Intercepting

static BOOL IsTollFreeBridged(Class class, id obj)
{
    // this is a naive check, but good enough for the purposes of failing fast
    return [NSStringFromClass(class) hasPrefix:@"NSCF"];
}

// Canonical class is the non-intercept, non-metaclass, class for an object.
//
// (e.g. [Animal class] would be canonical, not
// object_getClass([Animal class]), if the Animal class has not been touched
// by the intercept mechanism.

Class KWSetupObjectInterceptSupport(id anObject) {
    Class objectClass = object_getClass(anObject);

    if (IsTollFreeBridged(objectClass, anObject)) {
        [NSException raise:@"KWTollFreeBridgingInterceptException" format:@"Attempted to stub object of class %@. Kiwi does not support setting expectation or stubbing methods on toll-free bridged objects.", NSStringFromClass(objectClass)];
    }

    if (KWClassIsInterceptClass(objectClass))
        return objectClass;

    BOOL objectIsClass = KWObjectIsClass(anObject);
    Class canonicalClass =  objectIsClass ? anObject : objectClass;
    Class canonicalInterceptClass = KWInterceptClassForCanonicalClass(canonicalClass);
    Class interceptClass = objectIsClass ? object_getClass(canonicalInterceptClass) : canonicalInterceptClass;

    object_setClass(anObject, interceptClass);

    return interceptClass;
}

void KWSetupMethodInterceptSupport(Class interceptClass, SEL aSelector) {
    BOOL isMetaClass = class_isMetaClass(interceptClass);
    Method method = isMetaClass ? class_getClassMethod(interceptClass, aSelector)
                                : class_getInstanceMethod(interceptClass, aSelector);

    if (method == nil) {
        [NSException raise:NSInvalidArgumentException format:@"cannot setup intercept support for -%@ because no such method exists",
                                                             NSStringFromSelector(aSelector)];
    }

    const char *encoding = method_getTypeEncoding(method);
    IMP forwardingImplementation = KWForwardingImplementationForMethodEncoding(encoding);
    class_addMethod(interceptClass, aSelector, forwardingImplementation, encoding);
}

#pragma mark - Intercept Enabled Method Implementations

void KWInterceptedForwardInvocation(id anObject, SEL aSelector, NSInvocation* anInvocation) {
    NSMapTable *spiesMap = KWMessageSpiesForObject(anObject);
    for (KWMessagePattern *messagePattern in spiesMap) {
        if ([messagePattern matchesInvocation:anInvocation]) {
            NSArray *spies = [spiesMap objectForKey:messagePattern];

            for (id<KWMessageSpying> spy in spies) {
                [spy object:anObject didReceiveInvocation:anInvocation];
            }
        }
    }

    for (KWStub *stub in KWObjectStubsForObject(anObject)) {
        if ([stub processInvocation:anInvocation])
            return;
    }

    Class interceptClass = KWRestoreOriginalClass(anObject);
    [anInvocation invoke];
    // anObject->isa = interceptClass;
    object_setClass(anObject, interceptClass);
}

void KWInterceptedDealloc(id anObject, SEL aSelector) {
    KWClearMessageSpies(anObject);
    KWClearObjectStubs(anObject);
    KWRestoreOriginalClass(anObject);
}

Class KWInterceptedClass(id anObject, SEL aSelector) {
    Class interceptClass = object_getClass(anObject);
    Class originalClass = class_getSuperclass(interceptClass);
    return originalClass;
}

Class KWInterceptedSuperclass(id anObject, SEL aSelector) {
    Class interceptClass = object_getClass(anObject);
    Class originalClass = class_getSuperclass(interceptClass);
    Class originalSuperclass = class_getSuperclass(originalClass);
    return originalSuperclass;
}

#pragma mark - Managing Objects Stubs

void KWAssociateObjectStub(id anObject, KWStub *aStub, BOOL overrideExisting) {
    KWObjectStubsInit();

    NSMutableArray *stubs = KWObjectStubsForObject(anObject);
    if (stubs == nil) {
        stubs = [[NSMutableArray alloc] init];
        KWObjectStubsSet(anObject, stubs);
    }

    NSUInteger stubCount = [stubs count];

    for (NSUInteger i = 0; i < stubCount; ++i) {
        KWStub *existingStub = stubs[i];

        if ([aStub.messagePattern isEqualToMessagePattern:existingStub.messagePattern]) {
            if (overrideExisting) {
                [stubs removeObjectAtIndex:i];
                break;
            } else {
                return;
            }
        }
    }

    [stubs addObject:aStub];
}

#pragma mark - Managing Message Spies

void KWAssociateMessageSpy(id anObject, id aSpy, KWMessagePattern *aMessagePattern) {
    KWMessageSpiesInit();

    NSMapTable *spies = KWMessageSpiesForObject(anObject);
    if (spies == nil) {
        spies = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
        KWMessageSpiesSet(anObject, spies);
    }

    NSMutableArray *messagePatternSpies = [spies objectForKey:aMessagePattern];
    if (messagePatternSpies == nil) {
        messagePatternSpies = [[NSMutableArray alloc] init];
        [spies setObject:messagePatternSpies forKey:aMessagePattern];
    }


    if ([messagePatternSpies containsObject:aSpy])
        return;

    [messagePatternSpies addObject:aSpy];
}

#pragma mark - KWMessageSpies

static NSMapTable *KWMessageSpies = nil;

void KWMessageSpiesInit(void) {
    if (KWMessageSpies == nil) {
        KWMessageSpies = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    };
}

NSMapTable *KWMessageSpiesForObject(id anObject) {
    return [KWMessageSpies objectForKey:KWInterceptedObjectKey(anObject)];
}

void KWMessageSpiesSet(id anObject, NSMapTable *spies) {
    [KWMessageSpies setObject:spies forKey:KWInterceptedObjectKey(anObject)];
}

void KWClearObjectSpy(id anObject, id aSpy, KWMessagePattern *aMessagePattern) {
    NSMapTable *spyArrayDictionary = KWMessageSpiesForObject(anObject);
    NSMutableArray *spies = [spyArrayDictionary objectForKey:aMessagePattern];
    [spies removeObject:aSpy];
}

void KWClearMessageSpies(id anObject) {
    [KWMessageSpies removeObjectForKey:KWInterceptedObjectKey(anObject)];
}

void KWClearAllMessageSpies(void) {
    for (KWInterceptedObjectBlock key in KWMessageSpies) {
        id spiedObject = key();
        if (KWObjectClassRestored(spiedObject)) {
            continue;
        }
        KWRestoreOriginalClass(spiedObject);
    }
    [KWMessageSpies removeAllObjects];
}


#pragma mark KWObjectStubs

static NSMapTable *KWObjectStubs = nil;

void KWObjectStubsInit(void) {
    if (KWObjectStubs == nil) {
        KWObjectStubs = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    }
}

NSMutableArray *KWObjectStubsForObject(id anObject) {
    return [KWObjectStubs objectForKey:KWInterceptedObjectKey(anObject)];
}

void KWObjectStubsSet(id anObject, NSMutableArray *stubs) {
    [KWObjectStubs setObject:stubs forKey:KWInterceptedObjectKey(anObject)];
}

void KWClearObjectStubs(id anObject) {
    [KWObjectStubs removeObjectForKey:KWInterceptedObjectKey(anObject)];
}

void KWClearAllObjectStubs(void) {
    for (KWInterceptedObjectBlock key in KWObjectStubs) {
        id stubbedObject = key();
        if (KWObjectClassRestored(stubbedObject)) {
            continue;
        }
        KWRestoreOriginalClass(stubbedObject);
    }
    [KWObjectStubs removeAllObjects];
}

#pragma mark KWRestoredObjects

static NSMutableArray *KWRestoredObjects = nil;

BOOL KWObjectClassRestored(id anObject) {
    return [KWRestoredObjects containsObject:KWInterceptedObjectKey(anObject)];
}

Class KWRestoreOriginalClass(id anObject) {
    Class interceptClass = object_getClass(anObject);
    if (KWClassIsInterceptClass(interceptClass))
    {
        Class originalClass = class_getSuperclass(interceptClass);
        // anObject->isa = originalClass;
        object_setClass(anObject, originalClass);
    }
    [KWRestoredObjects addObject:anObject];
    return interceptClass;
}

#pragma mark KWInterceptedObjectKey

static void *kKWInterceptedObjectKey = &kKWInterceptedObjectKey;

KWInterceptedObjectBlock KWInterceptedObjectKey(id anObject) {
    KWInterceptedObjectBlock key = objc_getAssociatedObject(anObject, kKWInterceptedObjectKey);
    if (key == nil) {
        __weak id weakobj = anObject;
        key = ^{ return weakobj; };
        objc_setAssociatedObject(anObject, kKWInterceptedObjectKey, [key copy], OBJC_ASSOCIATION_COPY);
    }
    return key;
}

#pragma mark - Managing Stubs & Spies

void KWClearStubsAndSpies(void) {
    KWRestoredObjects = [NSMutableArray array];
    KWClearAllMessageSpies();
    KWClearAllObjectStubs();
    KWRestoredObjects = nil;
}
