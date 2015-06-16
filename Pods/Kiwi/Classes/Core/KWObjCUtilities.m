//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWObjCUtilities.h"
#import "KWStringUtilities.h"

#pragma mark - Objective-C Type Utilities

BOOL KWObjCTypeEqualToObjCType(const char *firstObjCType, const char *secondObjCType) {
    return strcmp(firstObjCType, secondObjCType) == 0;
}

BOOL KWObjCTypeIsNumeric(const char *objCType) {
    return KWObjCTypeIsFloatingPoint(objCType) || KWObjCTypeIsIntegral(objCType);
}

BOOL KWObjCTypeIsFloatingPoint(const char *objCType) {
    return strcmp(objCType, @encode(float)) == 0 || strcmp(objCType, @encode(double)) == 0;
}

BOOL KWObjCTypeIsIntegral(const char *objCType) {
    return KWObjCTypeIsSignedIntegral(objCType) || KWObjCTypeIsUnsignedIntegral(objCType);
}

BOOL KWObjCTypeIsSignedIntegral(const char *objCType) {
    return strcmp(objCType, @encode(char)) == 0 ||
           strcmp(objCType, @encode(int)) == 0 ||
           strcmp(objCType, @encode(short)) == 0 ||
           strcmp(objCType, @encode(long)) == 0 ||
           strcmp(objCType, @encode(long long)) == 0;
}

BOOL KWObjCTypeIsUnsignedIntegral(const char *objCType) {
    return strcmp(objCType, @encode(unsigned char)) == 0 ||
           strcmp(objCType, @encode(unsigned int)) == 0 ||
           strcmp(objCType, @encode(unsigned short)) == 0 ||
           strcmp(objCType, @encode(unsigned long)) == 0 ||
           strcmp(objCType, @encode(unsigned long long)) == 0;
}

BOOL KWObjCTypeIsBoolean(const char *objCType) {
    return strcmp(objCType, @encode(BOOL)) == 0 || strcmp(objCType, @encode(bool)) == 0;
}

BOOL KWObjCTypeIsObject(const char *objCType) {
    return strcmp(objCType, @encode(id)) == 0 || strcmp(objCType, "@?") == 0;
}

BOOL KWObjCTypeIsCharString(const char *objCType) {
    return strcmp(objCType, @encode(char *)) == 0;
}

BOOL KWObjCTypeIsClass(const char *objCType) {
    return strcmp(objCType, @encode(Class)) == 0;
}

BOOL KWObjCTypeIsSelector(const char *objCType) {
    return strcmp(objCType, @encode(SEL)) == 0;
}

BOOL KWObjCTypeIsPointerToType(const char *objCType) {
    return *objCType == '^';
}

BOOL KWObjCTypeIsPointerLike(const char *objCType) {
    return KWObjCTypeIsObject(objCType) ||
           KWObjCTypeIsCharString(objCType) ||
           KWObjCTypeIsClass(objCType) ||
           KWObjCTypeIsSelector(objCType) ||
           KWObjCTypeIsPointerToType(objCType);
}

BOOL KWObjCTypeIsUnknown(const char *objCType) {
    return *objCType == '?';
}

NSUInteger KWObjCTypeLength(const char *objCType) {
	NSUInteger typeSize = 0;
	NSGetSizeAndAlignment(objCType, &typeSize, NULL);
	return typeSize;
}

BOOL KWObjCTypeIsBlock(const char *objCType) {
    return strcmp(objCType, "@?") == 0;
}


#pragma mark - Selector Utlities

NSUInteger KWSelectorParameterCount(SEL selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    NSUInteger length = [selectorString length];
    NSUInteger parameterCount = 0;

    for (NSUInteger i = 0; i < length; ++i) {
        if ([selectorString characterAtIndex:i] == ':')
            ++parameterCount;
    }

    return parameterCount;
}
