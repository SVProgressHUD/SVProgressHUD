//
//  NSObject+KiwiAdditions.h
//  Kiwi
//
//  Created by Luke Redpath on 24/01/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KiwiGenericMatchingAdditions)

- (BOOL)isEqualOrMatches:(id)object DEPRECATED_ATTRIBUTE;

@end

@interface NSArray (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object DEPRECATED_ATTRIBUTE;
- (BOOL)containsObjectMatching:(id)matcher DEPRECATED_ATTRIBUTE;

@end

@interface NSSet (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object DEPRECATED_ATTRIBUTE;

@end

@interface NSOrderedSet (KiwiGenericMatchingAdditions)

- (BOOL)containsObjectEqualToOrMatching:(id)object DEPRECATED_ATTRIBUTE;

@end
