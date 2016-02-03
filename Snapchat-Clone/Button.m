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
    [UIView animateWithDuration: 0.1 delay: 0 usingSpringWithDamping: 0.85 initialSpringVelocity:1 options:kNilOptions animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
    
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration: 0.1 delay: 0 usingSpringWithDamping:.85 initialSpringVelocity:1 options:kNilOptions animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
}
@end
