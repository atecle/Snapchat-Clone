//
//  LoginViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "LoginViewController.h"

NSString * const LoginViewControllerIdentifier = @"LoginViewController";

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButtonPressed:(id)sender
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [APIClient authenticateForUser:username withPassword:password success:^(User *user, NSString *APIToken) {
        
        [self.delegate loginViewController:self didLoginUser:user withAPIToken:APIToken];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
