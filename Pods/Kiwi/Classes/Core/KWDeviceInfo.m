//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWDeviceInfo.h"

#if TARGET_IPHONE_SIMULATOR

#import <UIKit/UIKit.h>

#endif // #if TARGET_IPHONE_SIMULATOR

@implementation KWDeviceInfo

#pragma mark - Getting the Device Type

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif // #if TARGET_IPHONE_SIMULATOR
}

+ (BOOL)isPhysical {
    return ![self isSimulator];
}

@end
