//
//  SnapTextView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextOverlayView.h"
#import "CameraView.h"

static NSInteger CharacterLimit = 25;

@interface SnapTextOverlayView() <UITextFieldDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) SnapTextField *textField;
@property (strong, nonatomic) NSLayoutConstraint *textFieldHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldCenterYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldBottomConstraint;

@property (nonatomic) CGPoint textFieldPosition;

@end

@implementation SnapTextOverlayView

+ (instancetype)snapTextViewInView:(UIView *)superview
{
    SnapTextOverlayView *snapTextView = [[SnapTextOverlayView alloc] initWithView:superview];
    
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
        //[self configurePinchGesture];
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


#pragma mark - Instance Methods

- (void)changeTextAppearance
{
    if (self.textField.textStyle == SnapTextViewStyleDark)
    {
        self.textField.textStyle = SnapTextViewStyleClear;
        [self.textField setFont:[UIFont boldSystemFontOfSize:40]];
        [self.textField setBackgroundColor:[UIColor clearColor]];
        self.textFieldHeightConstraint.constant = 20;
        self.pinchGesture.enabled = NO;
    }
    else if (self.textField.textStyle == SnapTextViewStyleClear)
    {
        [self.textField setFont:[UIFont systemFontOfSize:16]];
        [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
        self.textField.textStyle = SnapTextViewStyleDark;
        self.textFieldHeightConstraint.constant = 0;
        self.pinchGesture.enabled = YES;
    }
    
    [self layoutIfNeeded];
    [self moveTextFieldIntoPositionAnimated:NO];
}

- (void)resetAppearance
{
    self.textField.text = @"";
    [self addGestureRecognizer:self.tapGesture];
    self.textFieldPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    if (self.textField.textStyle == SnapTextViewStyleClear) [self changeTextAppearance];
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
    
    self.textFieldHeightConstraint = heightConstraint;
    
    self.textFieldPosition = CGPointZero;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]];
}

- (void)configureTextField
{
    self.textField = [[SnapTextField alloc] init];
    self.textField.textStyle = SnapTextViewStyleDark;
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGesture.minimumPressDuration = 0.01f;
    [self.longPressGesture requireGestureRecognizerToFail:self.tapGesture];
    
    [self.textField addGestureRecognizer:self.longPressGesture];
    
    [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.textField setTextColor:[UIColor whiteColor]];
    
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)configureTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapTextViewTapped)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)configurePinchGesture
{
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:self.pinchGesture];
}

- (void)observeKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    
    if ([self.textField isFirstResponder]) return;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self changeSizeOfTextField:self.textField withGesture:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (void)changeSizeOfTextField:(UITextField *)textField withGesture:(UIPinchGestureRecognizer *)gesture
{
    textField.contentScaleFactor = gesture.scale;
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

- (void)moveTextFieldIntoPositionAnimated:(BOOL)animated
{
    [self removeConstraint:self.textFieldBottomConstraint];
    
    __block CGFloat centerYConstant = CGRectGetMidY(self.frame) - self.textFieldPosition.y;
    
    __weak typeof(self) weakSelf = self;
    void (^work)() = ^{
        __strong typeof(self) self = weakSelf;
        self.textFieldCenterYConstraint.constant = centerYConstant;
        [self addConstraint:self.textFieldCenterYConstraint];
        [self.superview layoutIfNeeded];
    };
    
    if (animated == YES)
    {
        [UIView animateWithDuration:.3 animations:^{
            work();
        }];
    }
    else
    {
        work();
    }
}

#pragma mark - Keyboard Observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    [self.textField setHidden:NO];
    [self addGestureRecognizer:self.tapGesture];
    self.textField.textAlignment = NSTextAlignmentLeft;
    [self animateTextFieldAboveKeyboard:keyboardFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.textField.text length] == 0 || self.enabled == NO)
    {
        self.textField.hidden = YES;
        [self addGestureRecognizer:self.tapGesture];
    }
    else
    {
        [self.textField addGestureRecognizer:self.tapGesture];
        self.textField.textAlignment = NSTextAlignmentCenter;
        [self moveTextFieldIntoPositionAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate 

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
