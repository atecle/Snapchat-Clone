//
//  SnapTextView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextView.h"

static NSInteger CharacterLimit = 25;

@interface SnapTextView() <UITextFieldDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) SnapTextField *textField;
@property (strong, nonatomic) NSLayoutConstraint *textFieldCenterYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldBottomConstraint;

@property (nonatomic) CGPoint textFieldPosition;

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
        self.enabled = NO;
        
        [self observeKeyboard];
        [self addConstraintsToSuperView];
        [self configureTapGesture];
        [self configureTextField];
        [self addConstraintsToTextField];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGPointEqualToPoint(self.textFieldPosition, CGPointZero))
    {
        self.textFieldPosition = CGPointMake(CGRectGetMidX(self.superview.frame), CGRectGetMidY(self.superview.frame));
    }
   
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
    
    self.textFieldCenterYConstraint = centerYConstraint;
    
    self.textFieldPosition = CGPointZero;
    
    NSLog(@"%f %f", CGRectGetMidX(self.superview.frame), CGRectGetMidY(self.superview.frame));
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]];
}

- (void)configureTextField
{
    self.textField = [[SnapTextField alloc] init];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGesture.minimumPressDuration = 0.01f;
    [self.textField addGestureRecognizer:self.longPressGesture];
    [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.textField setTextColor:[UIColor whiteColor]];
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)configureTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapTextViewTapped)];
    [self.textField addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)observeKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)configureForState:(BOOL)enabled
{
    if (enabled == YES)
    {
        self.textField.hidden = YES;
    }
    else
    {
        
    }
}

#pragma mark - User Interaction

- (void)snapTextViewTapped
{

    if ([self.textField isFirstResponder] == NO)
    {
        [self.textField becomeFirstResponder];
    }
    else
    {
        [self.textField resignFirstResponder];
    }
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    UITextField *textField = (UITextField *)gesture.view;
    
    if ([self.textField isFirstResponder]) return;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            [self grabTextField:textField withGesture:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self moveTextField:textField withGesture:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self dropTextField:textField withGesture:gesture];
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (void)grabTextField:(UITextField *)textField withGesture:(UILongPressGestureRecognizer *)gesture
{
    
}

- (void)moveTextField:(UITextField *)textField withGesture:(UILongPressGestureRecognizer *)gesture
{
    CGPoint gestureLocation = [gesture locationInView:self];
    
    if (gestureLocation.y >= CGRectGetHeight(self.frame) * 0.15 && gestureLocation.y <= CGRectGetHeight(self.frame) * 0.85)
    {
        textField.center = CGPointMake(textField.center.x, gestureLocation.y);
    }
}

- (void)dropTextField:(UITextField *)textField withGesture:(UILongPressGestureRecognizer *)gesture
{
    self.textFieldPosition = textField.center;
}


#pragma mark - UI Methods

- (void)animateTextFieldAboveKeyboard:(CGRect)keyboardFrame
{
    
    if (self.textFieldBottomConstraint == nil)
    {
        self.textFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1 constant:keyboardFrame.size.height];
    }
    
    __weak typeof(self) weakSelf = self;
    [self removeConstraint:self.textFieldCenterYConstraint];
    [UIView animateWithDuration:.3 animations:^{
        __strong typeof(self) self = weakSelf;
        self.textField.hidden = NO;
        [self addConstraint:self.textFieldBottomConstraint];
        [self.superview layoutIfNeeded];
    }];
}

//this will eventually place the text field into whatever position it was last moved
- (void)animateTextFieldIntoPosition
{
    [self removeConstraint:self.textFieldBottomConstraint];
    __block CGFloat centerYConstant = CGRectGetMidY(self.frame) - self.textFieldPosition.y;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        __strong typeof(self) self = weakSelf;
        
        self.textFieldCenterYConstraint.constant = centerYConstant;
        [self addConstraint:self.textFieldCenterYConstraint];
        [self.superview layoutIfNeeded];
    }];
}

- (void)clearText
{
    self.textField.text = @"";
}

#pragma mark - Keyboard Observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    [self.textField setHidden:NO];
    [self animateTextFieldAboveKeyboard:keyboardFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.textField.text length] == 0 || self.enabled == NO)
    {
        self.textField.hidden = YES;
    }
    else
    {
        [self animateTextFieldIntoPosition];
    }
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


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    if (self.enabled == NO)
    {
        return nil;
    }
    
    if (point.y < CGRectGetHeight(self.frame) * 0.15 || point.y > CGRectGetHeight(self.frame) * 0.85)
    {
        return nil;
    }
    
    UIView *view = [super hitTest:point withEvent:event];

    if (CGRectContainsPoint(self.textField.frame, point))
    {
        return self.textField;
    }

    return view;
}


#pragma mark - Helpers

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    self.textField.hidden = YES;
    [self.textField resignFirstResponder];
}

@end
