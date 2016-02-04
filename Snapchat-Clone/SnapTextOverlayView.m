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

@property (strong, nonatomic) SnapTextField *textField;
@property (strong, nonatomic) SnapTextView *textView;

@property (strong, nonatomic) UIPanGestureRecognizer *textFieldPanGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *textViewPanGesture;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) NSLayoutConstraint *textFieldHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textFieldBottomConstraint;

@property (strong, nonatomic) NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textViewBottomConstraint;

@property (nonatomic) CGFloat textFieldBottomConstraintConstant;
@property (nonatomic) CGFloat textViewBottomConstraintConstant;

@property (nonatomic, readonly) SnapTextMode snapTextMode;
@property (nonatomic, readonly) SnapTextMode previousSnapTextMode;

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
        
        [self configureBlurView];
        [self addConstraintsToBlurView];
        
        [self configureTapGesture];
        [self configurePinchGesture];
        
        [self configureTextField];
        [self observeTextField];
        [self addConstraintsToTextField];
        
        [self configureTextView];
        [self addConstraintsToTextView];
    
    }
    
    return self;
}

#pragma mark - Instance Methods

- (void)textStyleButtonPressed
{
    switch (self.snapTextMode) {
        case SnapTextModeHidden:
        {
            if (self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self setSnapTextMode:SnapTextModeNormal];
                
            }
            else
            {
                [self setSnapTextMode:self.previousSnapTextMode];
            }
            
            break;
        }
        case SnapTextModeNormal:
        {
            [self setSnapTextMode:SnapTextModeLight];
            break;
        }
        case SnapTextModeLight:
        {
            [self setSnapTextMode:SnapTextModeLightCentered];
            break;
        }
        case SnapTextModeLightCentered:
        {
            [self setSnapTextMode:SnapTextModeNormal];
            break;
        }
    }
}


- (void)hide
{
    [self setSnapTextMode:SnapTextModeHidden];
    _previousSnapTextMode = SnapTextModeHidden;
    
    self.snapText = @"";
    self.textField.text = @"";
    self.textView.text = @"";
    
    self.tapGesture.enabled = NO;
    
    self.textFieldBottomConstraintConstant = 0;
    self.textViewBottomConstraintConstant = 0;
    
    self.textFieldBottomConstraint.constant = self.textFieldBottomConstraintConstant;
    self.textViewBottomConstraint.constant = self.textViewBottomConstraintConstant;
    
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
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    
    self.textFieldHeightConstraint = heightConstraint;
    self.textFieldBottomConstraint = bottomConstraint;
    self.textFieldBottomConstraintConstant = 0;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, bottomConstraint]];
    
}

- (void)addConstraintsToTextView
{
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textView];
    
    CGFloat height = CGRectGetHeight(self.frame) * 0.0625;
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0 constant:height];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    self.textViewHeightConstraint = heightConstraint;
    self.textViewBottomConstraint = bottomConstraint;
    self.textViewBottomConstraintConstant = 0;
    
    [self addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, bottomConstraint]];
}

- (void)addConstraintsToBlurView
{
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.blurView];
    
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.blurView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.superview addConstraints:@[widthConstraint, heightConstraint, leftConstraint, rightConstraint, bottomConstraint, topConstraint]];
}

- (void)configureTextField
{
    self.textField = [[SnapTextField alloc] init];
    self.textField.textStyle = SnapTextViewStyleDark;
    self.textView.returnKeyType = UIReturnKeyDone;
    
    self.textFieldPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTextField:)];
    [self.textField addGestureRecognizer:self.textFieldPanGesture];
    self.textFieldPanGesture.enabled = NO;
    
    [self.textField setBackgroundColor:[UIColor  colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.textField setTextColor:[UIColor whiteColor]];
    
    self.textField.hidden = YES;
    self.textField.delegate = self;
}

- (void)observeTextField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
}

- (void)configureTextView
{
    self.textView = [[SnapTextView alloc] init];
    self.textView.returnKeyType = UIReturnKeyDone;
    
    self.textViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTextView:)];
    [self.textView addGestureRecognizer:self.textViewPanGesture];
    
    self.textView.hidden = YES;
    self.textView.delegate = self;
    [self.textView addObserver:self forKeyPath:@"contentSize" options: (NSKeyValueObservingOptionNew) context:nil];
}

- (void)configureBlurView
{
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurView.hidden = YES;
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
            [self setSnapTextMode:SnapTextModeNormal];
        }
        else
        {
            [self setSnapTextMode:self.previousSnapTextMode];
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
    if ([self.textField isFirstResponder] || [self.textView isFirstResponder] || self.snapTextMode == SnapTextModeHidden || self.snapTextMode == SnapTextModeNormal) return;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self changeSizeOfTextView:self.textView withGesture:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (void)dragTextField:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    
    if ([self textCanMoveToPoint:location] == NO) return;
    
    CGFloat bottomConstant = CGRectGetHeight(self.frame) - location.y;
    self.textFieldBottomConstraint.constant = bottomConstant;
    self.textFieldBottomConstraintConstant = self.textFieldBottomConstraint.constant;
    [self layoutIfNeeded];
}

- (void)dragTextView:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    
    if ([self textCanMoveToPoint:location] == NO) return;
    
    CGFloat bottomConstant = CGRectGetHeight(self.frame) - location.y;
    self.textViewBottomConstraint.constant = bottomConstant;
    self.textViewBottomConstraintConstant = self.textViewBottomConstraint.constant;
    [self layoutIfNeeded];
    
}

- (void)changeSizeOfTextView:(UITextView *)textView withGesture:(UIPinchGestureRecognizer *)gesture
{
    textView.transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
}

#pragma mark - UI

- (void)setSnapTextMode:(SnapTextMode)snapTextMode
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
            
           // self.textField.center = self.textView.center;
            
            self.textField.enabled = YES;
            
            if ([self.textView isFirstResponder] == YES || self.previousSnapTextMode == SnapTextModeHidden)
            {
                [self.textField becomeFirstResponder];
                self.blurView.hidden = YES;
            }
            
            if (self.textViewBottomConstraintConstant != self.textFieldBottomConstraintConstant)
            {
                self.textFieldBottomConstraintConstant = self.textViewBottomConstraintConstant;
                self.textFieldBottomConstraint.constant = self.textFieldBottomConstraintConstant;
                [self layoutIfNeeded];
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
                self.blurView.hidden = NO;
            }
            
            if (self.textViewBottomConstraintConstant != self.textFieldBottomConstraintConstant)
            {
                self.textViewBottomConstraintConstant = self.textFieldBottomConstraintConstant;
                self.textViewBottomConstraint.constant = self.textViewBottomConstraintConstant;
                [self layoutIfNeeded];
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
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        __strong typeof(self) self = weakSelf;
        self.textFieldBottomConstraint.constant = keyboardFrame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTextViewAboveKeyboard:(CGRect)keyboardFrame
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        __strong typeof(self) self = weakSelf;
        self.textViewBottomConstraint.constant = keyboardFrame.size.height;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)moveTextFieldIntoPositionAnimated:(BOOL)animated
{
    if (self.textFieldBottomConstraintConstant == 0)
    {
        self.textFieldBottomConstraintConstant = CGRectGetMidY(self.frame);
    }
    __weak typeof(self) weakSelf = self;
    void (^work)() = ^{
        __strong typeof(self) self = weakSelf;
        self.textFieldBottomConstraint.constant = self.textFieldBottomConstraintConstant;
        [self layoutIfNeeded];
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
    if (self.textViewBottomConstraintConstant == 0)
    {
        self.textViewBottomConstraintConstant = CGRectGetMidY(self.frame);
    }
    
    __weak typeof(self) weakSelf = self;
    void (^work)() = ^{
        __strong typeof(self) self = weakSelf;
        self.textViewBottomConstraint.constant = self.textViewBottomConstraintConstant;
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
        self.textFieldPanGesture.enabled = NO;
        [self animateTextFieldAboveKeyboard:keyboardFrame];
    }
    else
    {
        self.textViewPanGesture.enabled = NO;
        [self animateTextViewAboveKeyboard:keyboardFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.snapText length] == 0)
    {
        self.tapGesture.enabled = YES;
        self.textViewPanGesture.enabled = NO;
        self.textFieldPanGesture.enabled = NO;
        [self setSnapTextMode:SnapTextModeHidden];
        self.textFieldBottomConstraintConstant = 0;
        self.textViewBottomConstraintConstant = 0;
        self.textViewBottomConstraint.constant = self.textViewBottomConstraintConstant;
        self.textFieldBottomConstraint.constant = self.textFieldBottomConstraintConstant;
        self.blurView.hidden = YES;
        return;
    }
    
    self.tapGesture.enabled = NO;
    
    if (self.snapTextMode == SnapTextModeNormal)
    {
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textFieldPanGesture.enabled = YES;
        [self moveTextFieldIntoPositionAnimated:YES];
    }
    else
    {
        self.textViewPanGesture.enabled = YES;
        [self moveTextViewIntoPositionAnimated:YES];
        self.blurView.hidden = YES;
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
        [self setSnapTextMode:SnapTextModeHidden];
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

- (void)textViewDidChange:(UITextView *)textView
{
    self.snapText = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        [self setSnapTextMode:SnapTextModeHidden];
        self.tapGesture.enabled = YES;
        return;
    }
    
    return;
}

#pragma mark - Helpers

- (BOOL)textCanMoveToPoint:(CGPoint )location
{
    return (location.y > CGRectGetHeight(self.frame) * 0.2 && location.y < CGRectGetHeight(self.frame) * 0.8);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end
