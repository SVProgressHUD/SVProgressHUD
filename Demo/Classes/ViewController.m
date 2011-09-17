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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Show Methods Sample

- (void)show {
	[SVProgressHUD showInView:self.view];
}

- (void)showWithStatus {
	[SVProgressHUD showInView:self.view status:@"Doing Stuff"];
}

- (IBAction)showWithStatusLongMessage:(id)sender 
{
    [SVProgressHUD showInView:self.view status:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque at lorem non elit imperdiet ultricies eget eget augue."];
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
