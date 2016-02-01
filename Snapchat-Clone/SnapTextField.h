//
//  SnapTextField.h
//  Snapchat-Clone
//
//  Created by Adam on 1/28/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SnapTextViewStyle)
{
    SnapTextViewStyleDark,
    SnapTextViewStyleClear
};

@interface SnapTextField : UITextField

@property (nonatomic) SnapTextViewStyle textStyle;

@end
