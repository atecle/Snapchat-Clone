//
//  CameraView.h
//  Feed
//
//  Created by Adam on 1/19/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CameraButton.h"
#import "SnapTextView.h"

@class CameraView;

@protocol CameraViewDelegate <NSObject>

@required
- (void)cameraView:(CameraView *)cameraView didPressSnapButtonWithImage:(UIImage *)image;
- (void)cameraViewInboxButtonPressed:(CameraView *)cameraView;


@optional
- (void)cameraViewDidEnterCaptureMode:(CameraView *)cameraView;
- (void)cameraViewDidExitCaptureMode:(CameraView *)cameraView;
- (void)cameraViewCancelButtonPressed:(CameraView *)cameraView;

@end

@interface CameraView : UIView

@property (weak, nonatomic) id<CameraViewDelegate> delegate;

- (void)startCaptureSession;
- (void)stopCaptureSession;

@end
