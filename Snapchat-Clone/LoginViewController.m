//
//  LoginViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "LoginViewController.h"

NSString * const LoginViewControllerIdentifier = @"LoginViewController";

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Login", nil);
    
    [self.navigationItem.leftBarButtonItem setTitle:@""];
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)login
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    __block LoadingView *loadingView = [LoadingView loadingViewInView:self.view];
    [loadingView show];
    
    __weak typeof(self) weakSelf = self;
    [APIClient authenticateForUser:username withPassword:password success:^(User *user, NSString *APIToken) {
        __strong typeof(self) self = weakSelf;
        [self.delegate loginViewController:self didLoginUser:user withAPIToken:APIToken];
        [loadingView hide];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [loadingView hide];
    }];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self.passwordTextField resignFirstResponder];
        [self login];
    }
    else
    {
        [self.passwordTextField becomeFirstResponder];
    }
    
    return NO;
}


@end
