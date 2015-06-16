//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@interface KWFormatter : NSObject

#pragma mark - Getting Descriptions

+ (NSString *)formatObject:(id)anObject;
+ (NSString *)formatObjectIncludingClass:(id)anObject;

@end
