//
//  SnapTextView.h
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapTextField.h"

@interface SnapTextOverlayView : UIView

@property (nonatomic) BOOL enabled;

+ (instancetype)snapTextViewInView:(UIView *)superview;
- (instancetype)initWithView:(UIView *)superview;

- (void)resetAppearance;
- (void)changeTextAppearance;

@end
