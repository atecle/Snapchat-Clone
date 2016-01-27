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
- (void)cameraView:(CameraView *)cameraView didCaptureImage:(UIImage *)image;
- (void)cameraViewSendSnapButtonPressed:(CameraView *)cameraView;
- (void)cameraViewInboxButtonPressed:(CameraView *)cameraView;


@optional
- (void)cameraViewDidEnterCaptureMode:(CameraView *)cameraView;
- (void)cameraViewDidExitCaptureMode:(CameraView *)cameraView;
- (void)cameraViewCancelButtonPressed:(CameraView *)cameraView;

@end

@interface CameraView : UIView

@property (weak, nonatomic) id<CameraViewDelegate> delegate;
@property (strong, nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) BOOL hasImage;

- (void)startCaptureSession;
- (void)stopCaptureSession;
- (void)setImage:(UIImage *)image;
- (void)setHasImage:(BOOL)hasImage;
@end
