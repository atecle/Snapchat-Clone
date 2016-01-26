//
//  ProgressView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/26/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSLayoutConstraint *centerXConstraint;

//this property is for appearance/dismissal animation
@property (nonatomic) CGFloat centerXOffset;
@end

@implementation LoadingView


#pragma mark - Initialization

+ (instancetype)loadingViewInView:(UIView *)view
{
    LoadingView *loadingView = [[LoadingView alloc] initWithSuperView:view];
 
    return loadingView;
}

- (instancetype)initWithSuperView:(UIView *)superview
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        
        [superview addSubview:self];
        
        [self setBackgroundColor: [UIColor clearColor]];

        [self addConstraintsToSuperview];
        
        [self configureContentView];
        
        [self configureActivityIndicatorView];
        
        [self.superview layoutIfNeeded];
    }
    
    return self;
}

#pragma mark - Set up

- (void)configureContentView
{
    self.contentView = [[UIView alloc] init];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.contentView.layer.cornerRadius = 10;
    [self.contentView layoutIfNeeded];
    [self addSubview:self.contentView];
    [self addConstraintsToContentView];
}

- (void)configureActivityIndicatorView
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.contentView addSubview:self.activityIndicatorView];
    [self addConstraintsToIndicatorView];
}


- (void)addConstraintsToSuperview
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self];
    
    self.centerXOffset = CGRectGetWidth(self.superview.frame) * 2;

    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:self.centerXOffset];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1  constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1  constant:0];
    
    self.centerXConstraint = centerXConstraint;
    
    [self.superview addConstraints:@[topConstraint, bottomConstraint, rightConstraint, heightConstraint, centerXConstraint]];
}

- (void)addConstraintsToContentView
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
   [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.25 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0];
    
    [self addConstraints:@[centerXConstraint, centerYConstraint, heightConstraint, widthConstraint]];
}


- (void)addConstraintsToIndicatorView
{
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    
    [self addConstraints:@[centerXConstraint, centerYConstraint, heightConstraint, widthConstraint]];
}

#pragma mark - UI

- (void)showLoadingView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.2 animations:^{

        __strong typeof(self) self = weakSelf;
        [self.activityIndicatorView startAnimating];
        self.centerXConstraint.constant = 0;
        [self layoutIfNeeded];
    }];
    
}

- (void)hideLoadingView
{
    [self removeFromSuperview];
}

@end
