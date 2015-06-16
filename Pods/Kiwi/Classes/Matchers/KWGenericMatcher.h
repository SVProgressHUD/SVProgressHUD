//
//  KWGenericMatcher.h
//  Kiwi
//
//  Created by Luke Redpath on 24/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWMatcher.h"

@protocol KWGenericMatching <NSObject>

- (BOOL)matches:(id)object;

@end

@interface KWGenericMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)match:(id<KWGenericMatching>)aMatcher;

@end
