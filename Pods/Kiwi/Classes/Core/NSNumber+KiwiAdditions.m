//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "NSNumber+KiwiAdditions.h"
#import "KWObjCUtilities.h"

@implementation NSNumber(KiwiAdditions)

#pragma mark - Creating Numbers

+ (id)numberWithBytes:(const void *)bytes objCType:(const char *)anObjCType {
    // Yeah, this is ugly.
    if (KWObjCTypeEqualToObjCType(anObjCType, @encode(BOOL)))
        return [self numberWithBoolBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(bool)))
        return [self numberWithStdBoolBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(char)))
        return [self numberWithCharBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(double)))
        return [self numberWithDoubleBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(float)))
        return [self numberWithFloatBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(int)))
        return [self numberWithIntBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(NSInteger)))
        return [self numberWithIntegerBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(long)))
        return [self numberWithLongBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(long long)))
        return [self numberWithLongLongBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(short)))
        return [self numberWithShortBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned char)))
        return [self numberWithUnsignedCharBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned int)))
        return [self numberWithUnsignedIntBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(NSUInteger)))
        return [self numberWithUnsignedIntegerBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned long)))
        return [self numberWithUnsignedLongBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned long long)))
        return [self numberWithUnsignedLongLongBytes:bytes];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned short)))
        return [self numberWithUnsignedShortBytes:bytes];
    else
        return nil;
}

+ (id)numberWithBoolBytes:(const void *)bytes {
    return @(*(const BOOL *)bytes);
}

+ (id)numberWithStdBoolBytes:(const void *)bytes {
    return @(*(const bool *)bytes);
}

+ (id)numberWithCharBytes:(const void *)bytes {
    return @(*(const char *)bytes);
}

+ (id)numberWithDoubleBytes:(const void *)bytes {
    return @(*(const double *)bytes);
}

+ (id)numberWithFloatBytes:(const void *)bytes {
    return @(*(const float *)bytes);
}

+ (id)numberWithIntBytes:(const void *)bytes {
    return @(*(const int *)bytes);
}

+ (id)numberWithIntegerBytes:(const void *)bytes {
    return @(*(const NSInteger *)bytes);
}

+ (id)numberWithLongBytes:(const void *)bytes {
    return @(*(const long *)bytes);
}

+ (id)numberWithLongLongBytes:(const void *)bytes {
    return @(*(const long long *)bytes);
}

+ (id)numberWithShortBytes:(const void *)bytes {
    return @(*(const short *)bytes);
}

+ (id)numberWithUnsignedCharBytes:(const void *)bytes {
    return @(*(const unsigned char *)bytes);
}

+ (id)numberWithUnsignedIntBytes:(const void *)bytes {
    return @(*(const unsigned int *)bytes);
}

+ (id)numberWithUnsignedIntegerBytes:(const void *)bytes {
    return @(*(const NSUInteger *)bytes);
}

+ (id)numberWithUnsignedLongBytes:(const void *)bytes {
    return @(*(const unsigned long *)bytes);
}

+ (id)numberWithUnsignedLongLongBytes:(const void *)bytes {
    return @(*(const unsigned long long *)bytes);
}

+ (id)numberWithUnsignedShortBytes:(const void *)bytes {
    return @(*(const unsigned short *)bytes);
}

@end
