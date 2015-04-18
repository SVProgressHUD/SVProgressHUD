//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWValue.h"
#import "KWObjCUtilities.h"
#import "NSNumber+KiwiAdditions.h"

@interface KWValue()

#pragma mark - Properties

@property (nonatomic, readonly) id value;

@end

@implementation KWValue

#pragma mark - Initializing

- (id)initWithBytes:(const void *)bytes objCType:(const char *)anObjCType {
    self = [super init];
    if (self) {
        objCType = anObjCType;
        value = [[NSValue alloc] initWithBytes:bytes objCType:anObjCType];
    }

    return self;
}

+ (id)valueWithBytes:(const void *)bytes objCType:(const char *)type {
    return [[self alloc] initWithBytes:bytes objCType:type];
}

+ (id)valueWithBool:(BOOL)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(BOOL)];
}

+ (id)valueWithChar:(char)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(char)];
}

+ (id)valueWithDouble:(double)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(double)];
}

+ (id)valueWithFloat:(float)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(float)];
}

+ (id)valueWithInt:(int)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(int)];
}

+ (id)valueWithInteger:(NSInteger)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(NSInteger)];
}

+ (id)valueWithLong:(long)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(long)];
}

+ (id)valueWithLongLong:(long long)value {
    return [self valueWithBytes:&value objCType:@encode(long long)];
}

+ (id)valueWithShort:(short)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(short)];
}

+ (id)valueWithUnsignedChar:(unsigned char)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(unsigned char)];
}

+ (id)valueWithUnsignedInt:(unsigned int)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(unsigned int)];
}

+ (id)valueWithUnsignedInteger:(NSUInteger)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(NSUInteger)];
}

+ (id)valueWithUnsignedLong:(unsigned long)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(unsigned long)];
}

+ (id)valueWithUnsignedLongLong:(unsigned long long)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(long long)];
}

+ (id)valueWithUnsignedShort:(unsigned short)aValue {
    return [self valueWithBytes:&aValue objCType:@encode(unsigned short)];
}


#pragma mark - Properties

@synthesize objCType;

- (BOOL)isNumeric {
    return KWObjCTypeIsNumeric(self.objCType);
}

@synthesize value;

#pragma mark - Accessing Numeric Values

- (NSNumber *)numberValue {
    if (!KWObjCTypeIsNumeric(self.objCType) && !KWObjCTypeIsBoolean(self.objCType)) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"cannot return number value because wrapped value is non-numeric"];
    }

    NSData *data = [self dataValue];
    return [NSNumber numberWithBytes:[data bytes] objCType:self.objCType];
}

- (BOOL)boolValue {
    return [[self numberValue] boolValue];
}

- (char)charValue {
    return [[self numberValue] charValue];
}

- (double)doubleValue {
    return [[self numberValue] doubleValue];
}

- (float)floatValue {
    return [[self numberValue] floatValue];
}

- (int)intValue {
    return [[self numberValue] intValue];
}

- (NSInteger)integerValue {
    return [[self numberValue] integerValue];
}

- (long)longValue {
    return [[self numberValue] longValue];
}

- (long long)longLongValue {
    return [[self numberValue] longLongValue];
}
- (short)shortValue {
    return [[self numberValue] shortValue];
}

- (unsigned char)unsignedCharValue {
    return [[self numberValue] unsignedCharValue];
}

- (unsigned int)unsignedIntValue {
    return [[self numberValue] unsignedIntValue];
}

- (NSUInteger)unsignedIntegerValue {
    return [[self numberValue] unsignedIntegerValue];
}

- (unsigned long)unsignedLongValue {
    return [[self numberValue] unsignedLongValue];
}

- (unsigned long long)unsignedLongLongValue {
    return [[self numberValue] unsignedLongLongValue];
}

- (unsigned short)unsignedShortValue {
    return [[self numberValue] unsignedShortValue];
}

#pragma mark - Accessing Data

- (NSData *)dataValue {
    NSUInteger length = KWObjCTypeLength(self.objCType);
    void *buffer = malloc(length);
    [self.value getValue:buffer];
    NSData *data = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    return data;
}

- (void)getValue:(void *)buffer {
    [self.value getValue:buffer];
}

#pragma mark - Accessing Numeric Data

- (NSData *)dataForObjCType:(const char *)anObjCType {
    // Yeah, this is ugly.
    if (KWObjCTypeEqualToObjCType(anObjCType, @encode(BOOL)))
        return [self boolData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(char)))
        return [self charData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(double)))
        return [self doubleData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(float)))
        return [self floatData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(int)))
        return [self intData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(NSInteger)))
        return [self integerData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(long)))
        return [self longData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(long long)))
        return [self longLongData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(short)))
        return [self shortData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned char)))
        return [self unsignedCharData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned int)))
        return [self unsignedIntData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(NSUInteger)))
        return [self unsignedIntegerData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned long)))
        return [self unsignedLongData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned long long)))
        return [self unsignedLongLongData];
    else if (KWObjCTypeEqualToObjCType(anObjCType, @encode(unsigned short)))
        return [self unsignedShortData];
    else
        return nil;
}

- (NSData *)boolData {
    BOOL aValue = [self boolValue];
    return [NSData dataWithBytes:&aValue length:sizeof(BOOL)];
}

- (NSData *)charData {
    char aValue = [self charValue];
    return [NSData dataWithBytes:&aValue length:sizeof(char)];
}

- (NSData *)doubleData {
    double aValue = [self doubleValue];
    return [NSData dataWithBytes:&aValue length:sizeof(double)];
}

- (NSData *)floatData {
    float aValue = [self floatValue];
    return [NSData dataWithBytes:&aValue length:sizeof(float)];
}

- (NSData *)intData {
    int aValue = [self intValue];
    return [NSData dataWithBytes:&aValue length:sizeof(int)];
}

- (NSData *)integerData {
    NSInteger aValue = [self integerValue];
    return [NSData dataWithBytes:&aValue length:sizeof(NSInteger)];
}

- (NSData *)longData {
    long aValue = [self longValue];
    return [NSData dataWithBytes:&aValue length:sizeof(long)];
}

- (NSData *)longLongData {
    long long aValue = [self longLongValue];
    return [NSData dataWithBytes:&aValue length:sizeof(long long)];
}

- (NSData *)shortData {
    short aValue = [self shortValue];
    return [NSData dataWithBytes:&aValue length:sizeof(short)];
}

- (NSData *)unsignedCharData {
    unsigned char aValue = [self unsignedCharValue];
    return [NSData dataWithBytes:&aValue length:sizeof(unsigned char)];
}

- (NSData *)unsignedIntData {
    unsigned int aValue = [self unsignedIntValue];
    return [NSData dataWithBytes:&aValue length:sizeof(unsigned int)];
}

- (NSData *)unsignedIntegerData {
    NSUInteger aValue = [self unsignedIntegerValue];
    return [NSData dataWithBytes:&aValue length:sizeof(NSUInteger)];
}

- (NSData *)unsignedLongData {
    unsigned long aValue = [self unsignedLongValue];
    return [NSData dataWithBytes:&aValue length:sizeof(unsigned long)];
}

- (NSData *)unsignedLongLongData {
    unsigned long long aValue = [self unsignedLongLongValue];
    return [NSData dataWithBytes:&aValue length:sizeof(unsigned long long)];
}

- (NSData *)unsignedShortData {
    unsigned short aValue = [self unsignedShortValue];
    return [NSData dataWithBytes:&aValue length:sizeof(unsigned short)];
}

#pragma mark - Comparing Objects

- (NSUInteger)hash {
    if (self.isNumeric)
        return [[self numberValue] hash];

    return [self.value hash];
}

- (NSComparisonResult)compare:(KWValue *)aValue {
    return [[self numberValue] compare:[aValue numberValue]];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[KWValue class]])
        return [self isEqualToKWValue:object];

    if ([object isKindOfClass:[NSNumber class]])
      return [self isEqualToNumber:object];

    return NO;
}

- (BOOL)isEqualToKWValue:(KWValue *)aValue {
    if (self.isNumeric && aValue.isNumeric)
        return [self isEqualToNumber:[aValue numberValue]];
    else
        return [self.value isEqual:aValue.value];
}

- (BOOL)isEqualToNumber:(NSNumber *)aValue {
    return [[self numberValue] isEqualToNumber:aValue];
}

#pragma mark - Representing Values

- (NSString *)description {
    if ([self isNumeric])
        return [[self numberValue] description];

    return [self.value description];
}

@end
