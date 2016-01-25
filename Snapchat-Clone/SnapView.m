//
//  SnapView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/25/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapView.h"

@interface SnapView()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation SnapView


- (instancetype) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.imageView = [[UIImageView alloc] init];
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped)];
        [self addGestureRecognizer:self.tapGesture];
        [self addSubview:self.imageView];
        [self addConstraintsToImageView];
    }
    
    return self;
}

- (void)addConstraintsToImageView
{
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self addConstraint:topConstraint];
    [self addConstraint:bottomConstraint];
    [self addConstraint:rightConstraint];
    [self addConstraint:leftConstraint];
}

- (void)imageViewTapped
{
    [self.delegate snapViewDidRecieveTap:self];
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
    [self layoutIfNeeded];
}

@end
