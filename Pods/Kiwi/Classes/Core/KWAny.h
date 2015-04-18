//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

// KWAny exists to determine arguments in a message pattern that should
// match any value. Used for pointers as well as for scalar values.
@interface KWAny : NSObject

#pragma mark - Initializing

+ (id)any;

@end
