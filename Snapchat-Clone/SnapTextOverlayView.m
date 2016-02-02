//
//  SnapTextView.m
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextOverlayView.h"
#import "CameraView.h"
#import "SnapTextField.h"
#import "SnapTextView.h"

typedef NS_ENUM(NSInteger, SnapTextStyle)
{
    SnapTextStyleDefault,
    SnapTextStyleLight,
    SnapTextStyleLightCentered
};

static NSInteger CharacterLimit = 25;

@interface SnapTextOverlayView() <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;

@property (strong, nonatomic) SnapTextField *textField;
@property (strong, nonatomic) SnapTextView *textView;

@property (strong, nonatomic) NSLayoutConstraint *textFieldHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldCenterYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldBottomConstraint;

@property (strong, nonatomic) NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textViewBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textViewCenterYConstraint;

@property (nonatomic) CGPoint textFieldPosition;
@property (nonatomic) CGPoint textViewPosition;

@property (nonatomic) SnapTextStyle snapTextStyle;

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
        self.snapTextStyle = SnapTextStyleDefault;
        
        [self observeKeyboard];
        
        [self addConstraintsToSuperView];
        
        [self configureTapGesture];
        //[self configurePinchGesture];
        
        [self configureTextField];
        [self addConstraintsToTextField];
        
        [self configureTextView];
        [self addConstraintsToTextView];
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
    
    if ([self.textField isFirstResponder] == NO && [self.textView isFirstResponder] == NO)
    {
        if (self.snapTextStyle == SnapTextStyleDefault)
        {
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
        }
        else
        {
            self.textView.hidden = NO;
            [self.textView becomeFirstResponder];
        }
        return;
    }
    
    switch (self.snapTextStyle) {
        case SnapTextStyleDefault:
            self.snapTextStyle = SnapTextStyleLight;
            break;
        case SnapTextStyleLight:
            self.snapTextStyle = SnapTextStyleLightCentered;
            break;
        case SnapTextStyleLightCentered:
            self.snapTextStyle = SnapTextStyleDefault;
            break;
        default:
            break;
    }
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
    
    [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.textField setTextColor:[UIColor whiteColor]];
    
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)addConstraintsToTextView
{
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textView];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0625 constant:0];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    self.textViewHeightConstraint = heightConstraint;
    self.textViewCenterYConstraint = centerYConstraint;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]];
}

- (void)configureTextView
{
    self.textView = [[SnapTextView alloc] init];
    self.textView.hidden = YES;
    self.textView.delegate = self;
    [self.textView addObserver:self forKeyPath:@"contentSize" options: (NSKeyValueObservingOptionNew) context:nil];
    
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
    if (self.snapTextStyle == SnapTextStyleDefault)
    {
        if ([self.textField isFirstResponder] == NO)
        {
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
        }
        else
        {
            [self.textField resignFirstResponder];
        }
    }
    else
    {
        if ([self.textView isFirstResponder] == NO)
        {
            self.textView.hidden = NO;
            [self.textView becomeFirstResponder];
        }
        else
        {
            [self.textView resignFirstResponder];
        }
    }
    
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

#pragma mark - UI

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

- (void)animateTextViewAboveKeyboard:(CGRect)keyboardFrame
{
    if (self.textViewBottomConstraint == nil)
    {
        self.textViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1 constant:keyboardFrame.size.height];
    }
    __weak typeof(self) weakSelf = self;
    [self removeConstraint:self.textViewCenterYConstraint];
    [UIView animateWithDuration:.3 animations:^{
        __strong typeof(self) self = weakSelf;
        self.textField.hidden = NO;
        [self addConstraint:self.textViewBottomConstraint];
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

- (void)moveTextViewIntoPositionAnimated:(BOOL)animated
{
    [self removeConstraint:self.textViewBottomConstraint];
    
    __block CGFloat centerYConstant = CGRectGetMidY(self.frame) - self.textViewPosition.y;
    
    __weak typeof(self) weakSelf = self;
    void (^work)() = ^{
        __strong typeof(self) self = weakSelf;
        self.textViewCenterYConstraint.constant = centerYConstant;
        [self addConstraint:self.textViewCenterYConstraint];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"])
    {
        self.textViewHeightConstraint.constant = self.textView.contentSize.height;
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    
}

- (void)updateViewForSnapTextStyle
{
    if (self.snapTextStyle == SnapTextStyleDefault)
    {
        //we are currently editing text
        if ([self.textView isFirstResponder])
        {
            //remove visual effect
            [self.textView resignFirstResponder];
            self.textView.hidden = YES;
            
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
            self.textField.text = self.textView.text;
        }
        else
        {
            self.textView.hidden = YES;
            self.textField.hidden = NO;
            self.textField.text = self.textView.text;
        }
    }
    else if (self.snapTextStyle == SnapTextStyleLight)
    {
        
    }
    else if (self.snapTextStyle == SnapTextStyleLightCentered)
    {
        
    }
}

#pragma mark - Keyboard Observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    if (self.snapTextStyle == SnapTextStyleDefault)
    {
        
        [self.textField setHidden:NO];
        self.textField.textAlignment = NSTextAlignmentLeft;
        [self animateTextFieldAboveKeyboard:keyboardFrame];
    }
    else
    {
        [self.textView setHidden:NO];
        [self animateTextViewAboveKeyboard:keyboardFrame];
        
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //if in dark text state
    if ([self.textField.text length] == 0)
    {
        self.textField.hidden = YES;
        self.tapGesture.enabled = YES;
    }
    else
    {
        self.textField.textAlignment = NSTextAlignmentCenter;
        [self moveTextFieldIntoPositionAnimated:YES];
        self.tapGesture.enabled = NO;
    }
    
    //if in light text state
    if ([self.textView.text length] == 0)
    {
        self.textView.hidden = YES;
        self.tapGesture.enabled = YES;
    }
    else
    {
        [self moveTextViewIntoPositionAnimated:YES];
        self.tapGesture.enabled = NO;
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

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if ([textField.text length] == 0)
//    {
//        return;
//    }
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0)
    {
        self.tapGesture.enabled = YES;
        self.textField.hidden = YES;
        return;
    }
    
    self.tapGesture.enabled = NO;
    return;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [text length] + [textView.text length] <= CharacterLimit;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        self.tapGesture.enabled = YES;
        return;
    }
    
    self.tapGesture.enabled = NO;
    return;
}

#pragma mark - Helpers

- (void)setSnapTextStyle:(SnapTextStyle)snapTextStyle
{
    _snapTextStyle = snapTextStyle;
    [self updateViewForSnapTextStyle];
}

#pragma mark - Overrides

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    UIView *view = [super hitTest:point withEvent:event];
    
    if (CGRectContainsPoint(self.textField.frame, point))
    {
        return self.textField;
    }
    
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end
