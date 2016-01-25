//
//  CameraButton.m
//  Snapchat-Clone
//
//  Created by Adam on 1/21/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "CameraButton.h"

@implementation CameraButton

 - (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
      
    }
    
    return self;
}


- (void)layoutSubviews
{
    self.layer.borderWidth = 4.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = self.bounds.size.width / 2.0;
    self.backgroundColor = [UIColor translucentSilverColor];
    
}

@end
