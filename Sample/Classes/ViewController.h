//
//  SVProgressHUDViewController.h
//  SVProgressHUD
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (nonatomic, retain) IBOutlet UISwitch *modalSwitch;

- (IBAction)show;
- (IBAction)showWithStatus;

- (IBAction)dismiss;
- (IBAction)dismissSuccess;
- (IBAction)dismissError;

- (IBAction)modalChanged:(UISwitch*)sender;

@end

