//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

#pragma mark - Objective-C Type Utilities

BOOL KWObjCTypeEqualToObjCType(const char *firstObjCType, const char *secondObjCType);
BOOL KWObjCTypeIsNumeric(const char *objCType);
BOOL KWObjCTypeIsFloatingPoint(const char *objCType);
BOOL KWObjCTypeIsIntegral(const char *objCType);
BOOL KWObjCTypeIsSignedIntegral(const char *objCType);
BOOL KWObjCTypeIsUnsignedIntegral(const char *objCType);
BOOL KWObjCTypeIsBoolean(const char *objCType);
BOOL KWObjCTypeIsObject(const char *objCType);
BOOL KWObjCTypeIsCharString(const char *objCType);
BOOL KWObjCTypeIsClass(const char *objCType);
BOOL KWObjCTypeIsSelector(const char *objCType);
BOOL KWObjCTypeIsPointerToType(const char *objCType);
BOOL KWObjCTypeIsPointerLike(const char *objCType);
BOOL KWObjCTypeIsUnknown(const char *objCType);
BOOL KWObjCTypeIsBlock(const char *objCType);

NSUInteger KWObjCTypeLength(const char *objCType);

#pragma mark - Selector Utlities

NSUInteger KWSelectorParameterCount(SEL selector);
