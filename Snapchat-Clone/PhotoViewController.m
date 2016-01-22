//
//  ViewController.m
//  Snapchat-Clone
//
//  Created by Adam on 1/20/16.
//  Copyright © 2016 atecle. All rights reserved.
//

#import "PhotoViewController.h"

NSString * const PhotoViewControllerIdentifier = @"PhotoViewController";

@interface PhotoViewController () <CameraViewDelegate, FriendListViewControllerDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureConnection *captureConnection;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) APIClient *APIClient;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) CameraView *cameraView;
@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cameraView = [[CameraView alloc] init];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    [self addConstraintsToCameraView];
    [self.cameraView startCaptureSession];
    //[self.cameraView setBackgroundColor:[UIColor greenColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addConstraintsToCameraView
{
 
    self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cameraView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.view addConstraint:topConstraint];
    [self.view addConstraint:bottomConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view addConstraint:leftConstraint];
    [self.view addConstraint:heightConstraint];
    [self.view addConstraint:widthConstraint];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setAPIClient:(APIClient *)APIClient
{
    _APIClient = APIClient;
}

#pragma mark - CameraViewDelegate

- (void)cameraView:(CameraView *)cameraView didCaptureImage:(UIImage *)image
{
    self.image = image;
}

- (void)cameraViewSendSnapButtonPressed:(CameraView *)cameraView
{
    FriendListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:FriendListViewControllerIdentifier];
    
    [vc setAPIClient:self.APIClient];
    [vc setImage:self.image];
    vc.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)cameraViewInboxButtonPressed:(CameraView *)cameraView
{
    
}

#pragma mark - FriendListViewControllerDelegate

- (void)friendListViewControllerDidSendSnap:(FriendListViewController *)friendListViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    self.image = nil;
    [self.cameraView setImage:nil];
    [self.cameraView setHasImage:NO];
}

@end
