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
#import "PushNotificationProxy.h"

@class MasterViewController;

@protocol ContainedViewController <NSObject>

- (void)didBecomeVisibleViewControllerInMasterViewController:(MasterViewController *)masterViewController;

@end

@protocol MasterViewControllerDelegate <NSObject>

- (void)masterViewController:(MasterViewController *)masterViewController didInitializePushNotificationProxy:(PushNotificationProxy *)pushNotificationProxy;

@end

@interface MasterViewController : UIViewController

@property (weak, nonatomic) id<MasterViewControllerDelegate> delegate;

@end
