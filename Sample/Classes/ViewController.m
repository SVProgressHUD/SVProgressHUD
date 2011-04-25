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

@synthesize modalSwitch;

#pragma mark -
#pragma mark Show Methods Sample

- (void)show {
	[SVProgressHUD showInView:self.view];
    if (modalSwitch.on) [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
}

- (void)showWithStatus {
	[SVProgressHUD showInView:self.view status:@"Doing Stuff"];
    if (modalSwitch.on) [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
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

- (IBAction)modalChanged:(UISwitch*)sender {
    [SVProgressHUD setModal:sender.on];
}

- (void)dealloc {
    [modalSwitch release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setModalSwitch:nil];
    [super viewDidUnload];
}
@end
