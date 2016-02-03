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

typedef NS_ENUM(NSInteger, SnapTextMode)
{
    SnapTextModeHidden,
    SnapTextModeNormal,
    SnapTextModeLight,
    SnapTextModeLightCentered
};


//BUGS
//TextField registers input while hidden
//tap gesture response delayed when pressing cancel and navigating back

static NSInteger CharacterLimit = 25;

@interface SnapTextOverlayView() <UITextFieldDelegate, UITextViewDelegate>


@property (strong, nonatomic) NSString *snapText;

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

@property (nonatomic, readonly) SnapTextMode snapTextMode;
@property (nonatomic, readonly) SnapTextMode previousSnapTextMode;

@property (nonatomic) BOOL textFieldIsBeingMoved;
@property (nonatomic) BOOL textViewIsBeingMoved;


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
        
        [self observeKeyboard];
        
        [self addConstraintsToSuperView];
        
        [self configureTapGesture];
        //[self configurePinchGesture];
        
        [self configureTextField];
        [self observeTextField];
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
        self.textViewPosition = CGPointMake(CGRectGetMidX(self.superview.frame), CGRectGetMidY(self.superview.frame));
    }
}

#pragma mark - Instance Methods

- (void)textStyleButtonPressed
{
    switch (self.snapTextMode) {
        case SnapTextModeHidden:
        {
            if (self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self setSnapTextStyle:SnapTextModeNormal];

            }
            else
            {
                [self setSnapTextStyle:self.previousSnapTextMode];
            }
            
            break;
        }
        case SnapTextModeNormal:
        {
            [self setSnapTextStyle:SnapTextModeLight];
            break;
        }
        case SnapTextModeLight:
        {
            [self setSnapTextStyle:SnapTextModeLightCentered];
            break;
        }
        case SnapTextModeLightCentered:
        {
            [self setSnapTextStyle:SnapTextModeNormal];
            break;
        }
    }
}


- (void)hide
{
    [self setSnapTextStyle:SnapTextModeHidden];
    _previousSnapTextMode = SnapTextModeHidden;

    self.snapText = @"";
    self.textField.text = @"";
    self.textView.text = @"";
    
    self.tapGesture.enabled = NO;
    
    self.textFieldPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.textViewPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self layoutIfNeeded];
}

- (void)show
{
    self.tapGesture.enabled = YES;
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
    self.textView.returnKeyType = UIReturnKeyDone;
    
    [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.textField setTextColor:[UIColor whiteColor]];
    
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)observeTextField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
}

- (void)addConstraintsToTextView
{
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textView];
    
    CGFloat height = CGRectGetHeight(self.frame) * 0.0625;
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0 constant:height];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    self.textViewHeightConstraint = heightConstraint;
    self.textViewCenterYConstraint = centerYConstraint;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]];
}

- (void)configureTextView
{    
    self.textView = [[SnapTextView alloc] init];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.hidden = YES;
    self.textView.delegate = self;
    [self.textView addObserver:self forKeyPath:@"contentSize" options: (NSKeyValueObservingOptionNew) context:nil];
    
}

- (void)configureTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapTextViewTapped)];
    self.tapGesture.enabled = NO;
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
    if ([self.textField isFirstResponder] == NO && [self.textView isFirstResponder] == NO)
    {
        if (self.previousSnapTextMode == SnapTextModeHidden)
        {
            [self setSnapTextStyle:SnapTextModeNormal];
        }
        else
        {
            [self setSnapTextStyle:self.previousSnapTextMode];
        }
        return;
    }
    
    if (self.snapTextMode == SnapTextModeNormal)
    {
        [self.textField resignFirstResponder];
        return;
    }
    
    [self.textView resignFirstResponder];
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

- (void)setSnapTextStyle:(SnapTextMode)snapTextMode
{
    SnapTextMode oldSnapTextMode = self.snapTextMode;
    
    if (oldSnapTextMode == snapTextMode)
    {
        return;
    }
    
    switch (snapTextMode) {
        case SnapTextModeHidden:
        {
            _previousSnapTextMode = _snapTextMode;
            _snapTextMode = snapTextMode;
            
            [self.textView resignFirstResponder];
            [self.textField resignFirstResponder];
            
            self.textField.hidden = YES;
            self.textView.hidden = YES;
            
            self.textField.enabled = NO;
            self.textView.editable = NO;
            
            break;
        }
        case SnapTextModeNormal:
        {
            _previousSnapTextMode = _snapTextMode;
            _snapTextMode = snapTextMode;
            
            self.textField.enabled = YES;
            
            if ([self.textView isFirstResponder] == YES || self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self.textField becomeFirstResponder];
            }
            
            self.textField.hidden = NO;
            self.textView.hidden = YES;
            
            self.textView.editable = NO;
            
            self.textField.text = self.snapText;
            
            break;
        }
        case SnapTextModeLight:
        {
            _previousSnapTextMode = _snapTextMode;
            _snapTextMode = snapTextMode;
            
            self.textView.editable = YES;
            
            if ([self.textField isFirstResponder] == YES || self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self.textView becomeFirstResponder];
            }
            
            self.textField.hidden = YES;
            self.textView.hidden = NO;
            
            self.textField.enabled = NO;
            
            self.textView.text = self.snapText;
            self.textView.textAlignment = NSTextAlignmentLeft;
            
            break;
        }
        case SnapTextModeLightCentered:
        {
            _previousSnapTextMode = _snapTextMode;
            _snapTextMode = snapTextMode;
            
            self.textView.editable = YES;
            
            if ([self.textField isFirstResponder] || self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self.textView becomeFirstResponder];
            }
            
            self.textField.hidden = YES;
            self.textView.hidden = NO;
            
            self.textField.enabled = NO;
            
            self.textView.textAlignment = NSTextAlignmentCenter;
            
            break;
        }
    }
    
    [self layoutIfNeeded];
}

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
        [self addConstraint:self.textFieldBottomConstraint];
        [self layoutIfNeeded];
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
        self.textView.contentOffset = CGPointZero;
        [self.textView layoutIfNeeded];
    }
}

#pragma mark - Keyboard Observer

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.tapGesture.enabled = YES;
    
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    if (self.snapTextMode == SnapTextModeNormal)
    {
        self.textField.textAlignment = NSTextAlignmentLeft;
        [self animateTextFieldAboveKeyboard:keyboardFrame];
    }
    else
    {
        [self animateTextViewAboveKeyboard:keyboardFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.snapText length] == 0)
    {
        self.tapGesture.enabled = YES;
        [self setSnapTextStyle:SnapTextModeHidden];
        return;
    }
    
    self.tapGesture.enabled = NO;
    
    if (self.snapTextMode == SnapTextModeNormal)
    {
        self.textField.textAlignment = NSTextAlignmentCenter;
        [self moveTextFieldIntoPositionAnimated:YES];
    }
    else
    {
        [self moveTextViewIntoPositionAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[SnapTextField class]])
    {
        UITextField *textField = (UITextField *)notification.object;
        self.snapText = textField.text;
    }
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0)
    {
        [self setSnapTextStyle:SnapTextModeHidden];
        self.tapGesture.enabled = YES;
        return;
    }
    
    return;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return [text length] + [textView.text length] <= CharacterLimit;
}

//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    textView.selectedRange = NSMakeRange(self.snapText.length, 0);
//    [textView layoutIfNeeded];
//}

- (void)textViewDidChange:(UITextView *)textView
{
    self.snapText = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        [self setSnapTextStyle:SnapTextModeHidden];
        self.tapGesture.enabled = YES;
        return;
    }
    
    return;
}

#pragma mark - Overrides

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    if ([self.textView isFirstResponder] == YES || [self.textField isFirstResponder] == YES || self.snapTextMode == SnapTextModeHidden)
    {
        return;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (self.snapTextMode == SnapTextModeNormal)
    {
        if (CGRectContainsPoint(self.textField.frame, touchLocation))
        {
            self.textFieldIsBeingMoved = YES;
        }
    }
    else
    {
        if (CGRectContainsPoint(self.textView.frame, touchLocation))
        {
            self.textViewIsBeingMoved = YES;
        }
    }
    
    
    [super touchesBegan:touches withEvent:event];

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (self.textFieldIsBeingMoved == YES && [self textCanMoveToPoint:touchLocation])
    {
        self.textField.center = CGPointMake(self.textField.center.x, touchLocation.y);
    }
    else if (self.textViewIsBeingMoved == YES && [self textCanMoveToPoint:touchLocation])
    {
        self.textView.center = CGPointMake(self.textView.center.x, touchLocation.y);
    }
    [super touchesMoved:touches withEvent:event];

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (self.textFieldIsBeingMoved == YES)
    {
        self.textField.center = CGPointMake(self.textField.center.x, touchLocation.y);
        self.textFieldPosition = self.textField.center;
    }
    else if (self.textViewIsBeingMoved == YES)
    {
        self.textView.center = CGPointMake(self.textView.center.x, touchLocation.y);
        self.textViewPosition = self.textView.center;
    }
    
    [super touchesMoved:touches withEvent:event];

    
}

- (BOOL)textCanMoveToPoint:(CGPoint )location
{
    return (location.y > CGRectGetHeight(self.frame) * 0.2 && location.y < CGRectGetHeight(self.frame) * 0.8);
}

@end
