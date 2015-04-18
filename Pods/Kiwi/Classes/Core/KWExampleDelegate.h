//
//  KWExampleGroupDelegate.h
//  Kiwi
//
//  Created by Luke Redpath on 08/09/2011.
//  Copyright 2011 Allen Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KWExample;
@class KWFailure;

@protocol KWExampleDelegate <NSObject>

- (void)example:(KWExample *)example didFailWithFailure:(KWFailure *)failure;

@end
