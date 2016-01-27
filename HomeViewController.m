//
//  HomeViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "HomeViewController.h"
#import "MasterViewController.h"

NSString * const HomeViewControllerIdentifier = @"HomeViewController";

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading te view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender
{
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:LoginViewControllerIdentifier];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    vc.delegate = self.loginDelegate;
    
    [self.navigationController pushViewController:vc animated:NO];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
