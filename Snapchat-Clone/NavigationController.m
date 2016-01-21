//
//  NavigationController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController () <ContainedViewController>

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.topViewController preferredStatusBarUpdateAnimation];
}

#pragma mark - ContainedViewController

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController
{
    NSLog(@"In PhotoVC");
}


@end
