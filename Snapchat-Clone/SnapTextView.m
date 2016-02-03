//
//  SnapTextView.m
//  Snapchat-Clone
//
//  Created by Adam on 2/1/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextView.h"

@implementation SnapTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor whiteColor]];
        [self setFont:[UIFont boldSystemFontOfSize:40]];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesBegan:touches withEvent:event];
}

@end
