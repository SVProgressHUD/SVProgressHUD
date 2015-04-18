//
//  KWFutureObject.h
//  iOSFalconCore
//
//  Created by Luke Redpath on 13/01/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^KWFutureObjectBlock)(void);

@interface KWFutureObject : NSObject

+ (id)objectWithObjectPointer:(id *)pointer;
+ (id)futureObjectWithBlock:(KWFutureObjectBlock)block;
- (id)initWithBlock:(KWFutureObjectBlock)aBlock;
- (id)object;

@end
