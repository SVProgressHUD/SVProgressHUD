//
//  ViewController.m
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2018 Sam Vermette and contributors. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@interface ViewController()

@property (nonatomic, readwrite) NSUInteger activityCount;
@property (weak, nonatomic) IBOutlet UIButton *popActivityButton;

@end

@implementation ViewController


#pragma mark - ViewController lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.activityCount = 0;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidReceiveTouchEventNotification
                                               object:nil];
    
    [self addObserver:self forKeyPath:@"activityCount" options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - Notification handling

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if([notification.name isEqualToString:SVProgressHUDDidReceiveTouchEventNotification]){
        [self dismiss];
    }
}


#pragma mark - Show Methods Sample

- (void)show {
    [SVProgressHUD show];
    self.activityCount++;
}

- (void)showWithStatus {
	[SVProgressHUD showWithStatus:@"Doing Stuff"];
    self.activityCount++;
}

static float progress = 0.0f;

- (IBAction)showWithProgress:(id)sender {
    progress = 0.0f;
    [SVProgressHUD showProgress:0 status:@"Loading"];
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    self.activityCount++;
}

- (void)increaseProgress {
    progress += 0.05f;
    [SVProgressHUD showProgress:progress status:@"Loading"];

    if(progress < 1.0f){
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    } else {
        if (self.activityCount > 1) {
            [self performSelector:@selector(popActivity) withObject:nil afterDelay:0.4f];
        } else {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
        }
    }
}


#pragma mark - Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
    self.activityCount = 0;
}

- (IBAction)popActivity {
    [SVProgressHUD popActivity];
    
    if (self.activityCount != 0) {
        self.activityCount--;
    }
}

- (IBAction)showInfoWithStatus {
    [SVProgressHUD showInfoWithStatus:@"Useful Information."];
    self.activityCount++;
}

- (void)showSuccessWithStatus {
	[SVProgressHUD showSuccessWithStatus:@"Great Success!"];
    self.activityCount++;
}

- (void)showErrorWithStatus {
	[SVProgressHUD showErrorWithStatus:@"Failed with Error"];
    self.activityCount++;
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
    } else {
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
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


#pragma mark - Helper

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"activityCount"]){
        unsigned long activityCount = [[change objectForKey:NSKeyValueChangeNewKey] unsignedLongValue];
        [self.popActivityButton setTitle:[NSString stringWithFormat:@"popActivity - %lu", activityCount] forState:UIControlStateNormal];
    }
}

@end
