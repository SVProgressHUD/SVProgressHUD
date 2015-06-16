//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import <objc/runtime.h>

@class KWMessagePattern;
@class KWStub;

#pragma mark - Getting Forwarding Implementations

IMP KWRegularForwardingImplementation(void);
IMP KWStretForwardingImplementation(void);
IMP KWForwardingImplementationForMethodEncoding(const char* encoding);

#pragma mark - Getting Intercept Class Information

BOOL KWObjectIsClass(id anObject);
BOOL KWClassIsInterceptClass(Class aClass);
NSString *KWInterceptClassNameForClass(Class aClass);
Class KWInterceptClassForCanonicalClass(Class canonicalClass);
Class KWRealClassForClass(Class aClass);

#pragma mark - Enabling Intercepting

Class KWSetupObjectInterceptSupport(id anObject);
void KWSetupMethodInterceptSupport(Class interceptClass, SEL aSelector);

#pragma mark - Managing Stubs & Spies
void KWClearStubsAndSpies(void);

#pragma mark - Managing Objects Stubs

void KWAssociateObjectStub(id anObject, KWStub *aStub, BOOL overrideExisting);
void KWClearObjectStubs(id anObject);
void KWClearAllObjectStubs(void);

#pragma mark - Managing Message Spies

void KWAssociateMessageSpy(id anObject, id aSpy, KWMessagePattern *aMessagePattern);
void KWClearObjectSpy(id anObject, id aSpy, KWMessagePattern *aMessagePattern);
void KWClearAllMessageSpies(void);
