//
//  ViewController.m
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright (c) 2011-2014 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@implementation ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

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

- (void)handleNotification:(NSNotification *)notification{
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
    progress+=0.1f;
    [SVProgressHUD showProgress:progress status:@"Loading"];

    if(progress < 1.0f)
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
    else
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
}


#pragma mark - Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
}

- (IBAction)showInfoWithStatus{
    [SVProgressHUD showInfoWithStatus:@"Useful Information."];
}

- (void)showSuccessWithStatus {
	[SVProgressHUD showSuccessWithStatus:@"Great Success!"];
}

- (void)showErrorWithStatus {
	[SVProgressHUD showErrorWithStatus:@"Failed with Error"];
}

#pragma mark - Styling
- (IBAction)changeStyle:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    } else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
}

- (IBAction)changeAnimationType:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    } else {
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    }

}

- (IBAction)changeMaskType:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    } else if(segmentedControl.selectedSegmentIndex == 1){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    } else if(segmentedControl.selectedSegmentIndex == 2){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    } else {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    }
}


@end
