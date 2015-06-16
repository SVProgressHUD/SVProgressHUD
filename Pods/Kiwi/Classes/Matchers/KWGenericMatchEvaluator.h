//
//  KWGenericMatcher.h
//  Kiwi
//
//  Created by Allen Ding on 1/31/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWGenericMatchEvaluator : NSObject

+ (BOOL)isGenericMatcher:(id)object;

+ (BOOL)genericMatcher:(id)matcher matches:(id)object;

@end
