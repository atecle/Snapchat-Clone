//
//  SnapTextView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextView.h"

static NSInteger CharacterLimit = 150;

@interface SnapTextView() <UITextFieldDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSLayoutConstraint *centerYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldToKeyboardBottomConstraint;

@end

@implementation SnapTextView

+ (instancetype)snapTextViewInView:(UIView *)superview
{
    SnapTextView *snapTextView = [[SnapTextView alloc] initWithView:superview];
    
    return snapTextView;
}

- (instancetype)initWithView:(UIView *)superview
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        [superview addSubview:self];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self observeKeyboard];
        [self addConstraintsToSuperView];
        [self configureTapGesture];
        [self configureTextField];
        [self addConstraintsToTextField];
    }
    
    return self;
}

#pragma mark - Set up

- (void)addConstraintsToSuperView
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.superview addConstraints:@[widthConstraint, heightConstraint, leftConstraint, rightConstraint, bottomConstraint, topConstraint]];
}

- (void)addConstraintsToTextField
{
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textField];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0625 constant:0];

    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    self.centerYConstraint = centerYConstraint;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]];
}

- (void)configureTextField
{
    self.textField = [[UITextField alloc] init];
    [self.textField setBackgroundColor:[UIColor blackColor]];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setAlpha:0.5];
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)configureTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapTextViewTapped)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)observeKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

#pragma mark - User Interaction

- (void)snapTextViewTapped
{
    
    [self.textField becomeFirstResponder];
//    if ([self.textField isFirstResponder])
//    {
//        NSLog(@"Snap View Tapped");
//        [self dismissTextField];
//    }
//    else
//    {
//        [self showTextField];
//    }
}


#pragma mark - UI Methods

- (void)showTextField
{
    self.textField.hidden = NO;
    
}

- (void)dismissTextField
{
    if ([self.textField.text length] != 0)
    {
        [self placeTextField];
    }
    else
    {
        self.textField.hidden = YES;
    }
}

- (void)placeTextField
{
    
}

- (void)animateTextFieldAboveKeyboard
{
  //  NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLAyoutAttributeBottom multiplier:1 constant:0];
}

#pragma mark - Keyboard Observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self animateTextFieldAboveKeyboard];
}

- (void)keyboardWillHide:(NSNotification *)notification
{

}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"Text field tapped");
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [string length] + [textField.text length] <= CharacterLimit;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text length] == 0)
    {
        return;
    }
    
}

#pragma mark - Overrides

//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (CGRectContainsPoint(self.textField.bounds, point))
//    {
//        return self;
//    }
//
//    return nil;
//}


#pragma mark - Helpers



@end
