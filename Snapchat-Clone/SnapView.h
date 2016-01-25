//
//  SnapView.h
//  Snapchat-Clone
//
//  Created by Adam on 1/25/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapView;

@protocol SnapViewDelegate <NSObject>

- (void)snapViewDidRecieveTap:(SnapView *)snap;

@end


@interface SnapView : UIView

@property (weak, nonatomic) id<SnapViewDelegate> delegate;
- (void)setImage:(UIImage *)image;

@end
