//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

#pragma mark - Checking for Case Separated Words

BOOL KWStringHasWordPrefix(NSString *string, NSString *prefix);
BOOL KWStringHasStrictWordPrefix(NSString *string, NSString *prefix);
BOOL KWStringHasWord(NSString *string, NSString *word);

#pragma mark - Getting Type Encodings

NSString *KWEncodingWithObjCTypes(const char *firstType, ...) NS_REQUIRES_NIL_TERMINATION;
NSString *KWEncodingForVoidMethod(void);
NSString *KWEncodingForDefaultMethod(void);
