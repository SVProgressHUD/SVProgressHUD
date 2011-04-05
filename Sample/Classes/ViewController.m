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

#pragma mark -
#pragma mark Show Methods Sample

- (void)show {
	[SVProgressHUD showInView:self.view];
}

- (void)showWithStatus {
	[SVProgressHUD showInView:self.view status:@"Doing Stuff"];
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
