//
//  SVIndefiniteAnimatedView.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2019 Guillaume Campagna. All rights reserved.
//

#import <UIKit/UIKit.h>

extern UIScreen * SVCurrentScreen(void) ;
extern CGFloat SVCurrentScreenScale(void) ;


@interface SVIndefiniteAnimatedView : UIView

@property (nonatomic, assign) CGFloat strokeThickness;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *strokeColor;

@end

