//
//  SnapTextField.m
//  Snapchat-Clone
//
//  Created by Adam on 1/28/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "SnapTextField.h"

@implementation SnapTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

@end
