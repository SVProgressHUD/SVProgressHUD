//
//  ViewController.m
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@implementation ViewController


#pragma mark - Notification Methods Sample
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDWillAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDWillDisappearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
}

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification recieved: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
}


#pragma mark - Show Methods Sample

- (void)show {
	[SVProgressHUD show];
}

- (void)showWithStatus {
	[SVProgressHUD showWithStatus:@"Doing Stuff"];
}

static float progress = 0.0f;

- (IBAction)showWithProgress:(id)sender {
    progress = 0.0f;
    [SVProgressHUD showProgress:0 status:@"Loading"];
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
}

- (void)increaseProgress {
    progress += 0.1f;
    [SVProgressHUD showProgress:progress status:@"Loading"];

    if(progress < 1.0f){
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
    } else {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
    }
}


#pragma mark - Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
}

- (IBAction)showInfoWithStatus {
    [SVProgressHUD showInfoWithStatus:@"Useful Information."];
}

- (void)showSuccessWithStatus {
	[SVProgressHUD showSuccessWithStatus:@"Great Success!"];
}

- (void)showErrorWithStatus {
	[SVProgressHUD showErrorWithStatus:@"Failed with Error"];
}


#pragma mark - Styling

- (IBAction)changeStyle:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    } else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
}

- (IBAction)changeAnimationType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    } else if(segmentedControl.selectedSegmentIndex == 1){
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    }
    else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"ico_loading00"],
                                     [UIImage imageNamed:@"ico_loading01"],
                                     [UIImage imageNamed:@"ico_loading02"],
                                     [UIImage imageNamed:@"ico_loading03"],
                                     [UIImage imageNamed:@"ico_loading04"],
                                     [UIImage imageNamed:@"ico_loading05"],
                                     [UIImage imageNamed:@"ico_loading06"],
                                     [UIImage imageNamed:@"ico_loading07"],
                                     [UIImage imageNamed:@"ico_loading08"],
                                     [UIImage imageNamed:@"ico_loading09"],
                                     [UIImage imageNamed:@"ico_loading10"],
                                     [UIImage imageNamed:@"ico_loading11"], nil];
        imageView.animationDuration = 1.0f;
        imageView.animationRepeatCount = 0;
        [imageView startAnimating];
        [SVProgressHUD setLoadingImageView:imageView];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeCustom];
    }
}

- (IBAction)changeMaskType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    } else if(segmentedControl.selectedSegmentIndex == 1){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    } else if(segmentedControl.selectedSegmentIndex == 2){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    } else if(segmentedControl.selectedSegmentIndex == 3){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    } else {
        [SVProgressHUD setBackgroundLayerColor:[[UIColor redColor] colorWithAlphaComponent:0.4]];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    }
}


@end
