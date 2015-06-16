//
//  KWProbe.h
//  iOSFalconCore
//
//  Created by Luke Redpath on 13/01/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KWProbe <NSObject>
- (BOOL)isSatisfied;
- (void)sample;
@end
