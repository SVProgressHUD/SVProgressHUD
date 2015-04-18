//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

@class KWCallSite;

@protocol KWVerifying<NSObject>

@property (nonatomic, readonly) KWCallSite *callSite;

- (NSString *)descriptionForAnonymousItNode;

#pragma mark - Subjects

@property (nonatomic, strong) id subject;

#pragma mark - Ending Examples

- (void)exampleWillEnd;

@end
