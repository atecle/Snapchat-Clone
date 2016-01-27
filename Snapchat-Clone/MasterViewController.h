//
//  MasterViewController.h
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoViewController.h"
#import "InboxViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"

@class MasterViewController;

@protocol ContainedViewController <NSObject>

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController;

@end

@interface MasterViewController : UIViewController

@end
