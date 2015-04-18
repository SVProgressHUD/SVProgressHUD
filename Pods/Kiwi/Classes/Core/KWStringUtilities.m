//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWStringUtilities.h"

#pragma mark - Checking for Case Separated Words

BOOL KWStringHasWordPrefix(NSString *string, NSString *prefix) {
    return [string isEqualToString:prefix] || KWStringHasStrictWordPrefix(string, prefix);
}

BOOL KWStringHasStrictWordPrefix(NSString *string, NSString *prefix) {
    if (![string hasPrefix:prefix] || [string length] == [prefix length])
        return NO;

    unichar firstCharacterAfterPrefix = [string characterAtIndex:[prefix length]];
    NSCharacterSet *uppercaseCharacterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    return [uppercaseCharacterSet characterIsMember:firstCharacterAfterPrefix];
}

BOOL KWStringHasWord(NSString *string, NSString *word) {
    if (KWStringHasWordPrefix(string, word))
        return YES;

    NSCharacterSet *lowercaseCharacterSet = [NSCharacterSet lowercaseLetterCharacterSet];
    NSCharacterSet *uppercaseCharacterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange searchRange = NSMakeRange(0, [string length]);

    // Never match if word begins with a lowercase letter and was not a prefix.
    if ([lowercaseCharacterSet characterIsMember:[word characterAtIndex:0]])
        return NO;

    while (1) {
        if (searchRange.location >= [string length])
            return NO;

        NSRange range = [string rangeOfString:word options:0 range:searchRange];
        searchRange.location = range.location + range.length;
        searchRange.length = [string length] - searchRange.location;

        if (range.location == NSNotFound)
            return NO;

        if (range.location > 0) {
            unichar charBeforeRange = [string characterAtIndex:range.location - 1];


            if (![lowercaseCharacterSet characterIsMember:charBeforeRange])
                continue;
        }

        if (range.location + range.length < [string length]) {
            unichar charAfterRange = [string characterAtIndex:range.location + range.length];

            if (![uppercaseCharacterSet characterIsMember:charAfterRange])
                continue;
        }

        return YES;
    }
}

#pragma mark - Getting Type Encodings

NSString *KWEncodingWithObjCTypes(const char *firstType, ...) {
    if (firstType == nil)
        return nil;

    NSMutableString *encoding = [NSMutableString stringWithCapacity:8];
    va_list argumentList;
    va_start(argumentList, firstType);
    const char *type = firstType;

    do {
        [encoding appendFormat:@"%s", type];
        type = va_arg(argumentList, const char *);
    } while (type != nil);

    va_end(argumentList);
    return encoding;
}

NSString *KWEncodingForVoidMethod(void) {
    return KWEncodingWithObjCTypes(@encode(void), @encode(id), @encode(SEL), nil);
}

NSString *KWEncodingForDefaultMethod(void) {
    return KWEncodingWithObjCTypes(@encode(id), @encode(id), @encode(SEL), nil);
}
