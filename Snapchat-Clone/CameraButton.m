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
        self.layer.borderWidth = 3;
        self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
        self.layer.cornerRadius = self.bounds.size.width / 2.0;
        self.backgroundColor = [UIColor translucentSilverColor];
    }
    
    return self;
}


@end
