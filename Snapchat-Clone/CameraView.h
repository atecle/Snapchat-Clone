//
//  CameraView.h
//  Feed
//
//  Created by Adam on 1/19/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "FriendListViewController.h"
#import "CameraButton.h"
#import "SnapTextView.h"

@class CameraView;

@protocol CameraViewDelegate <NSObject>

@optional
- (void)cameraView:(CameraView *)cameraView didPressSnapButtonWithImage:(UIImage *)image;
- (void)cameraViewDidPressTextStyleButton:(CameraView *)cameraView;
- (void)cameraViewDidPressInboxButton:(CameraView *)cameraView;
- (void)cameraViewDidEnterCaptureMode:(CameraView *)cameraView;
- (void)cameraViewDidExitCaptureMode:(CameraView *)cameraView;
- (void)cameraViewDidPressCancelButton:(CameraView *)cameraView;
- (void)cameraView:(CameraView *)cameraView didSelectMediaFromImagePickerController:(UIImagePickerController *)imagePickerController;

@end

@interface CameraView : UIView

@property (weak, nonatomic) id<CameraViewDelegate> delegate;

- (void)resetToCameraMode;
- (void)startCaptureSession;
- (void)stopCaptureSession;

@end
