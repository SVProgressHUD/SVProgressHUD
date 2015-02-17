//
//  UIImage+Framework.m
//  SVProgressHUD
//
//  Created by Loïs Di Qual on 2/16/15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

#import "UIImage+Framework.h"

@implementation UIImage (Framework)

+ (UIImage *)imageNamed:(NSString *)name classInFramework:(Class)aClass {
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle* bundle = [NSBundle bundleForClass:aClass];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    }
    
    return [UIImage imageNamed:name];
}

@end
