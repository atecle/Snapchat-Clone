//
//  LoginViewController.h
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "APIClient.h"

extern NSString * const LoginViewControllerIdentifier;

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewController:(LoginViewController *)loginViewController didLoginWithAPIToken:(NSString *)APIToken;
- (void)loginViewController:(LoginViewController *)loginViewController didFailToLoginWithError:(NSString *)error;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end
