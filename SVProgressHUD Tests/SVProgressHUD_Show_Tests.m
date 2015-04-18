//
//  SVProgressHUD_Show_Tests.m
//  SVProgressHUD
//
//  Created by Daniele Bogo on 18/04/2015.
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


SPEC_BEGIN(SVProgressHUD_Show_Tests)

describe(@"SVProgressHUD - Show methods", ^{
    
    let(progressHUD, ^{
        return [SVProgressHUD sharedView];
    });
    
    
    context(@"setting if loader is visible", ^{
        
        [SVProgressHUD show];
        
        BOOL isVisible = [SVProgressHUD isVisible];
        
        it(@"the view should be visible", ^{
            
            [[theValue(isVisible) should] equal:theValue(YES)];
        });
    });
    
});

SPEC_END