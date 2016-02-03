//
//  SnapTextView.h
//  Snapchat-Clone
//
//  Created by Adam on 1/27/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapTextOverlayView : UIView

+ (instancetype)snapTextViewInView:(UIView *)superview;
- (instancetype)initWithView:(UIView *)superview;

- (void)show;
- (void)hide;
- (void)textStyleButtonPressed;

@end
