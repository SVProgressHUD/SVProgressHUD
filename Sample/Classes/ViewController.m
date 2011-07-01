//
//  SVProgressHUDViewController.m
//  SVProgressHUD
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@implementation ViewController

@synthesize segmentedControl;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Show Methods Sample

- (void)show {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            [SVProgressHUD showInView:self.view status:nil networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
            break;
        case 2:
            [SVProgressHUD showInView:self.view status:nil networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeBlack];
            break;
        default:
            [SVProgressHUD showInView:self.view];
            break;
    }
}

- (void)showWithStatus {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            [SVProgressHUD showInView:self.view status:@"Doing Stuff" networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
            break;
        case 2:
            [SVProgressHUD showInView:self.view status:@"Doing Stuff" networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeBlack];
            break;
        default:
            [SVProgressHUD showInView:self.view status:@"Doing Stuff"];;
            break;
    }
}

#pragma mark -
#pragma mark Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
}

- (void)dismissSuccess {
	[SVProgressHUD dismissWithSuccess:@"Great Success!"];
}

- (void)dismissError {
	[SVProgressHUD dismissWithError:@"Failed with Error"];
}

@end
