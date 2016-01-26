//
//  ProgressView.h
//  Snapchat-Clone
//
//  Created by Adam on 1/26/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+ (instancetype) loadingViewInView:(UIView *)view;

- (void)show;
- (void)hide;

@end
