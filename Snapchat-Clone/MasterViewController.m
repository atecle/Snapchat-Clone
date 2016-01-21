//
//  MasterViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIViewController<ContainedViewController> *rightViewController;
@property (strong, nonatomic) UIViewController<ContainedViewController> *leftViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rightViewController = [[NavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:PhotoViewControllerIdentifier]];
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:InboxViewControllerIdentifier];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.rightViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //[self.rightViewController.view setBackgroundColor:[UIColor greenColor]];
    //[self.leftViewController.view setBackgroundColor:[UIColor blueColor]];
    
    [self addChildViewController:self.rightViewController];
    [self addChildViewController:self.leftViewController];
    
    [self.scrollView addSubview:self.rightViewController.view];
    [self.scrollView addSubview:self.leftViewController.view];
    
    [self addConstraintsTorightViewController];
    [self addConstraintsToleftViewController];
    
}

- (void)addConstraintsTorightViewController
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

- (void)addConstraintsToleftViewController
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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

@end
