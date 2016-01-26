//
//  ProgressView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/26/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setBackgroundColor: [UIColor clearColor]];
        
        [self configureContentView];
        
        [self configureActivityIndicatorView];
    }
    
    return self;
}

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


- (void)startAnimating
{
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating
{
    [self.activityIndicatorView stopAnimating];
}

- (void)setIsDisplayed:(BOOL)isDisplayed
{
    _isDisplayed = isDisplayed;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self && self.isDisplayed == NO)
    {
        return nil;
    }
    
    return hitView;
}

@end
