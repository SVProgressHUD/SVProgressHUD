//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

// KWNull exists to represent the same thing as NSNull, except that Kiwi needs
// to distinguish between null singletons used internally and those a user
// is using as an object parameter.
@interface KWNull : NSObject

#pragma mark - Initializing

+ (id)null;

@end
