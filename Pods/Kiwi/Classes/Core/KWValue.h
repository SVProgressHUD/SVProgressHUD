//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface KWValue : NSObject

#pragma mark - Initializing

- (id)initWithBytes:(const void *)bytes objCType:(const char *)anObjCType;

+ (id)valueWithBytes:(const void *)bytes objCType:(const char *)anObjCType;
+ (id)valueWithBool:(BOOL)aValue;
+ (id)valueWithChar:(char)aValue;
+ (id)valueWithDouble:(double)aValue;
+ (id)valueWithFloat:(float)aValue;
+ (id)valueWithInt:(int)aValue;
+ (id)valueWithInteger:(NSInteger)aValue;
+ (id)valueWithLong:(long)aValue;
+ (id)valueWithLongLong:(long long)value;
+ (id)valueWithShort:(short)aValue;
+ (id)valueWithUnsignedChar:(unsigned char)aValue;
+ (id)valueWithUnsignedInt:(unsigned int)aValue;
+ (id)valueWithUnsignedInteger:(NSUInteger)aValue;
+ (id)valueWithUnsignedLong:(unsigned long)aValue;
+ (id)valueWithUnsignedLongLong:(unsigned long long)aValue;
+ (id)valueWithUnsignedShort:(unsigned short)aValue;

#pragma mark - Properties

@property (nonatomic, readonly) const char *objCType;
@property (nonatomic, readonly) BOOL isNumeric;

#pragma mark - Accessing Numeric Values

- (NSNumber *)numberValue;
- (BOOL)boolValue;
- (char)charValue;
- (double)doubleValue;
- (float)floatValue;
- (int)intValue;
- (NSInteger)integerValue;
- (long)longValue;
- (long long)longLongValue;
- (short)shortValue;
- (unsigned char)unsignedCharValue;
- (unsigned int)unsignedIntValue;
- (NSUInteger)unsignedIntegerValue;
- (unsigned long)unsignedLongValue;
- (unsigned long long)unsignedLongLongValue;
- (unsigned short)unsignedShortValue;

#pragma mark - Accessing Data

- (NSData *)dataValue;
- (void)getValue:(void *)buffer;

#pragma mark - Accessing Numeric Data

- (NSData *)dataForObjCType:(const char *)anObjCType;
- (NSData *)boolData;
- (NSData *)charData;
- (NSData *)doubleData;
- (NSData *)floatData;
- (NSData *)intData;
- (NSData *)integerData;
- (NSData *)longData;
- (NSData *)longLongData;
- (NSData *)shortData;
- (NSData *)unsignedCharData;
- (NSData *)unsignedIntData;
- (NSData *)unsignedIntegerData;
- (NSData *)unsignedLongData;
- (NSData *)unsignedLongLongData;
- (NSData *)unsignedShortData;

#pragma mark - Comparing Values

- (NSComparisonResult)compare:(KWValue *)aValue;

- (BOOL)isEqualToKWValue:(KWValue *)aValue;
- (BOOL)isEqualToNumber:(NSNumber *)aValue;

@end
