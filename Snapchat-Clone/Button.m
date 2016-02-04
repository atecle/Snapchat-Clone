//
//  Button.m
//  Snapchat-Clone
//
//  Created by Adam on 2/3/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "Button.h"

@implementation Button

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UIViewAnimationOptions animationOptions = (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState);

    [UIView animateWithDuration:.2 delay:0 options:animationOptions animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UIViewAnimationOptions animationOptions = (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState);
    [UIView animateWithDuration:.2 delay:0 options:animationOptions animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    UIViewAnimationOptions animationOptions = (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState);
    
    [UIView animateWithDuration:.2 delay:0 options:animationOptions animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
