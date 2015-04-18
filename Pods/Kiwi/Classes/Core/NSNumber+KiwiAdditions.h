//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface NSNumber(KiwiAdditions)

#pragma mark - Creating Numbers

+ (id)numberWithBytes:(const void *)bytes objCType:(const char *)anObjCType;
+ (id)numberWithBoolBytes:(const void *)bytes;
+ (id)numberWithStdBoolBytes:(const void *)bytes;
+ (id)numberWithCharBytes:(const void *)bytes;
+ (id)numberWithDoubleBytes:(const void *)bytes;
+ (id)numberWithFloatBytes:(const void *)bytes;
+ (id)numberWithIntBytes:(const void *)bytes;
+ (id)numberWithIntegerBytes:(const void *)bytes;
+ (id)numberWithLongBytes:(const void *)bytes;
+ (id)numberWithLongLongBytes:(const void *)bytes;
+ (id)numberWithShortBytes:(const void *)bytes;
+ (id)numberWithUnsignedCharBytes:(const void *)bytes;
+ (id)numberWithUnsignedIntBytes:(const void *)bytes;
+ (id)numberWithUnsignedIntegerBytes:(const void *)bytes;
+ (id)numberWithUnsignedLongBytes:(const void *)bytes;
+ (id)numberWithUnsignedLongLongBytes:(const void *)bytes;
+ (id)numberWithUnsignedShortBytes:(const void *)bytes;

@end
