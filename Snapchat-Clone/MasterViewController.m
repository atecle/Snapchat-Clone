//
//  MasterViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "MasterViewController.h"
#import "NavigationController.h"

@interface MasterViewController () <UIScrollViewDelegate, LoginViewControllerDelegate, InboxViewControllerDelegate>

@property (strong, nonatomic) NavigationController<ContainedViewController> *rightViewController;
@property (strong, nonatomic) InboxViewController<ContainedViewController> *leftViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSString *APIToken;

@property (strong, nonatomic) APIClient *APIClient;

@property (strong, nonatomic) User *user;
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.bounces = NO;
    
    [self configureChildViewControllers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //Putting showLoginViewController in viewDidAppear instead of viewDidLoad because of warning "Attemptingto present * on * whose view is not in the window

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.APIToken = [userDefaults stringForKey:@"APIToken"];
    self.user = [[User alloc] initFromDictionary:[userDefaults objectForKey:@"User"]];
    
    if (self.APIToken == nil)
    {
        [self showHomeViewController];
    }
    else
    {
        _APIClient = [[APIClient alloc] initWithAPIToken:self.APIToken];
        PhotoViewController *photoVC = (PhotoViewController *)self.rightViewController.topViewController;
        [photoVC setAPIClient: self.APIClient];
        [self.leftViewController setAPIClient:self.APIClient];
        [self.leftViewController setUser:self.user];
        [self.leftViewController didBecomeVisibleViewControllerInMasterViewController:self];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup

- (void)configureChildViewControllers
{
    self.rightViewController = [[NavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:PhotoViewControllerIdentifier]];
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:InboxViewControllerIdentifier];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.rightViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.leftViewController.delegate = self;
    //[self.rightViewController.view setBackgroundColor:[UIColor greenColor]];
    //[self.leftViewController.view setBackgroundColor:[UIColor blueColor]];
    
    [self addChildViewController:self.rightViewController];
    [self addChildViewController:self.leftViewController];
    
    [self.scrollView addSubview:self.rightViewController.view];
    [self.scrollView addSubview:self.leftViewController.view];
    
    [self addConstraintsToRightViewController];
    [self addConstraintsToLeftViewController];
}

- (void)addConstraintsToRightViewController
{
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rightViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.rightViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightViewController.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.rightViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.rightViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.view addConstraint:topConstraint];
    [self.view addConstraint:bottomConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view addConstraint:heightConstraint];
    [self.view addConstraint:widthConstraint];
}

- (void)addConstraintsToLeftViewController
{
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.leftViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.leftViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftViewController.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightViewController.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self.view addConstraint:topConstraint];
    [self.view addConstraint:bottomConstraint];
    [self.view addConstraint:leftConstraint];
    [self.view addConstraint:heightConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view addConstraint:widthConstraint];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)loginViewController didLoginUser:(User *)user withAPIToken:(NSString *)APIToken
{
    [[NSUserDefaults standardUserDefaults] setObject:APIToken forKey:@"APIToken"];
    NSDictionary *dictionary = [User dictionaryFromUser:user];
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"User"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _APIClient = [[APIClient alloc] initWithAPIToken:APIToken];
    
    PhotoViewController *photoVC = (PhotoViewController *)self.rightViewController.topViewController;
    [photoVC setAPIClient: self.APIClient];
    [self.leftViewController setAPIClient:self.APIClient];
    [self.leftViewController setUser:user];
    
    self.user = user;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewController:(LoginViewController *)loginViewController didFailToLoginWithError:(NSString *)error
{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint position = scrollView.contentOffset;
    CGFloat frameWidth = CGRectGetWidth(scrollView.frame);
    
    NSInteger page = position.x/frameWidth;
    
    if (page == 0)
    {
        [self.leftViewController didBecomeVisibleViewControllerInMasterViewController:self];
    }
    else
    {
        [self.rightViewController didBecomeVisibleViewControllerInMasterViewController:self];
    }
}

#pragma mark - Navigation

- (void) showHomeViewController
{
    HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:HomeViewControllerIdentifier];
    
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - InboxViewControllerDelegate

- (void)inboxViewControllerDidShowSnap:(InboxViewController *)inboxViewController
{
    self.scrollView.scrollEnabled = NO;
}

- (void)inboxViewControllerDidDismissSnap:(id)inboxViewController
{
    self.scrollView.scrollEnabled = YES;
}

@end
