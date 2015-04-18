//
//  SVProgressHUD_Customization_Tests.m
//  SVProgressHUD Tests
//
//  Created by Matteo Gobbi on 18/04/2015.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kiwi/Kiwi.h>
#import "SVProgressHUD.h"
#import "SVIndefiniteAnimatedView.h"

@interface SVProgressHUD (ExposePrivate)

@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UILabel *stringLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SVIndefiniteAnimatedView *indefiniteAnimatedView;

+ (SVProgressHUD *)sharedView;

@end


SPEC_BEGIN(SVProgressHUD_Customization_Tests)

describe(@"SVProgressHUD - Customization methods", ^{

    let(progressHUD, ^{
        return [SVProgressHUD sharedView];
    });
    
    context(@"setting the background color to red", ^{
        
        UIColor *color = [UIColor redColor];
        [SVProgressHUD setBackgroundColor:color];
        
        it(@"the hudView color should be red", ^{
            
            [[progressHUD.hudView.backgroundColor should] equal:color];
            
        });
        
        UIColor *color_wrong = [UIColor greenColor];
        
        it(@"the hudView color should not be green", ^{
            
            [[progressHUD.hudView.backgroundColor shouldNot] equal:color_wrong];
            
        });
    
    });
    
});

SPEC_END