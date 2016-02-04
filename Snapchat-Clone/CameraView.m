//
//  CameraView.m
//  Feed
//
//  Created by Adam on 1/19/16.
//  Copyright © 2016 ;. All rights reserved.
//

#import "CameraView.h"
#import "Button.h"

static NSInteger ButtonMargin = 20;
static NSInteger CameraButtonHeight = 80;
static NSInteger TextStyleButtonHeight = 30;
static NSInteger FlipCameraButtonHeight = 40;
static NSInteger CheckBoxButtonHeight = 45;
static NSInteger CancelButtonHeight = 30;
static NSInteger CancelButtonWidth = 30;

/**
 TODO
 - transform scale animation when flip camera button/text style  pressed
 - factor out AVCaptureSession 
 - Fix alignment of buttons/sizing. It's ugly af right now.

 **/

@interface CameraView()

//could refactor this out
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *backCameraDeviceInput;
@property (strong, nonatomic) AVCaptureDeviceInput *frontCameraDeviceInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureConnection *captureConnection;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) UIView *snapContainerView;
@property (strong, nonatomic) SnapTextOverlayView *snapTextOverlayView;
@property (strong, nonatomic) UIImageView *capturedImageView;
@property (strong, nonatomic) CameraButton *cameraButton;
@property (strong, nonatomic) Button *textStyleButton;
@property (strong, nonatomic) Button *flipCameraButton;
@property (strong, nonatomic) Button *sendSnapButton;
@property (strong, nonatomic) Button *cancelButton;
@property (strong, nonatomic) Button *inboxButton;
@property (strong, nonatomic) Button *pickImageButton;

@property (nonatomic) BOOL cameraFlipped;

@property (nonatomic) BOOL hasImage;

@end

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self configureCaptureSession];
        [self configureCameraView];
        [self configureSnapContainerView];
        [self configureCameraButton];
        [self configureFlipCameraButton];
        [self configureTextStyleButton];
        [self configureSendSnapButton];
        [self configureInboxButton];
        [self configureCancelButton];
        
#if TARGET_IPHONE_SIMULATOR
        [self configurePickImageButton];
#endif
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.previewLayer.frame = self.bounds;
}

#pragma mark  - Setup

- (void)configurePickImageButton
{
    self.pickImageButton = [[Button alloc] init];
    [self addSubview:self.pickImageButton];
    [self.pickImageButton addTarget:self action:@selector(pickImageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.pickImageButton setTitle:NSLocalizedString(@"PICK AN IMAGE", nil) forState:UIControlStateNormal];
    
    self.pickImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.pickImageButton.backgroundColor = [UIColor grayColor];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.pickImageButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.pickImageButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.pickImageButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.pickImageButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    
    [self addConstraints:@[centerXConstraint, centerYConstraint, heightConstraint, widthConstraint]];
}

- (void)configureCaptureSession
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *backCameraCaptureDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    NSError *error;
    
    AVCaptureDeviceInput *backCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCameraCaptureDevice error:&error];
    
    //back camera input
    if (backCameraDeviceInput == nil)
    {
        NSLog(@"%@", error);
        return;
    }
    
    if (![captureSession canAddInput:backCameraDeviceInput])
    {
        NSLog(@"Couldn't add input");
        return;
    }
    
    [captureSession addInput:backCameraDeviceInput];
    self.backCameraDeviceInput = backCameraDeviceInput;
    
    AVCaptureDevice *frontCameraCaptureDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    
    AVCaptureDeviceInput *frontCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCameraCaptureDevice error:&error];
    
    if (frontCameraDeviceInput == nil)
    {
        NSLog(@"%@", error);
        return;
    }
        
    self.frontCameraDeviceInput = frontCameraDeviceInput;
    
    //output config
    
    AVCaptureStillImageOutput *captureOutput = [[AVCaptureStillImageOutput alloc] init];
    
    if (![captureSession canAddOutput:captureOutput])
    {
        NSLog(@"Couldn't add output");
        return;
    }
    
    [captureSession addOutput:captureOutput];
    
    // NSNumber *pixelFormat = [captureOutput.availableImageDataCVPixelFormatTypes firstObject];
    NSDictionary *outputSettings =
    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    captureOutput.outputSettings = outputSettings;
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.captureSession = captureSession;
    self.captureOutput = captureOutput;
    self.previewLayer = previewLayer;
}

- (void)configureCameraView
{
    [self.layer addSublayer:self.previewLayer];
}

- (void)configureSnapContainerView
{
    
    self.snapContainerView = [[UIView alloc] init];
    self.snapContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.snapContainerView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.snapContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.snapContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.snapContainerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.snapContainerView attribute:NSLayoutAttributeRight multiplier:1 constant:0];

    [self addConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint]];
    
    [self configureSnapTextOverlayView];
    [self configureImageView];
}


- (void)configureSnapTextOverlayView
{
    self.snapTextOverlayView = [SnapTextOverlayView snapTextViewInView:self.snapContainerView];
}

- (void)configureImageView
{
    self.capturedImageView = [[UIImageView alloc] init];
    self.capturedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.snapContainerView addSubview:self.capturedImageView];
    [self.snapContainerView sendSubviewToBack:self.capturedImageView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.snapContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.snapContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.snapContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.snapContainerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.snapContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self.snapContainerView addConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint, heightConstraint]];
}

- (void)configureCameraButton
{
    CameraButton *cameraButton = [[CameraButton alloc] init];
    cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton layoutIfNeeded];
    
    [self addSubview:cameraButton];
    
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cameraButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cameraButton attribute:NSLayoutAttributeBottom multiplier:1 constant:ButtonMargin];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cameraButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CameraButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cameraButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CameraButtonHeight];
    
    self.cameraButton = cameraButton;
    
    self.capturedImageView.hidden = YES;
    
    [self addConstraints:@[centerConstraint, bottomConstraint, heightConstraint, widthConstraint]];
}

- (void)configureTextStyleButton
{
    self.textStyleButton = [[Button alloc] init];
    self.textStyleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.textStyleButton.hidden = YES;
    [self.textStyleButton setImage:[UIImage imageNamed:@"text-icon-white"] forState:UIControlStateNormal];
    [self.textStyleButton addTarget:self action:@selector(textStyleButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.textStyleButton addTarget:self action:@selector(textStyleButtonReleased) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.textStyleButton];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.textStyleButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRightMargin relatedBy:NSLayoutRelationEqual toItem:self.textStyleButton attribute:NSLayoutAttributeRight multiplier:1 constant:10];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.textStyleButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:TextStyleButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.textStyleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:TextStyleButtonHeight];
    
    [self addConstraints:@[topConstraint, rightConstraint, heightConstraint, widthConstraint]];
}

- (void)configureFlipCameraButton
{
    Button *flipCameraButton = [[Button alloc] init];
    [flipCameraButton setImage:[UIImage imageNamed:@"flip-camera-icon"] forState:UIControlStateNormal];
    flipCameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    flipCameraButton.adjustsImageWhenHighlighted = NO;
    [flipCameraButton addTarget:self action:@selector(flipCameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [flipCameraButton layoutIfNeeded];
    
    [self addSubview:flipCameraButton];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:flipCameraButton attribute:NSLayoutAttributeRight multiplier:1 constant:ButtonMargin];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FlipCameraButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FlipCameraButtonHeight];
    
    self.flipCameraButton = flipCameraButton;
    self.flipCameraButton.hidden = NO;
    
    [self addConstraints:@[rightConstraint, topConstraint, heightConstraint, widthConstraint]];
}

- (void)configureSendSnapButton
{
    Button *sendSnapButton = [[Button alloc] init];
    [sendSnapButton setImage:[UIImage imageNamed:@"white-angle-arrow"] forState:UIControlStateNormal];
    sendSnapButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendSnapButton addTarget:self action:@selector(sendSnapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:sendSnapButton];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:sendSnapButton attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:sendSnapButton attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:sendSnapButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CameraButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:sendSnapButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CameraButtonHeight];
    
    [self addConstraint:rightConstraint];
    [self addConstraint:bottomConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    
    sendSnapButton.hidden = YES;
    self.sendSnapButton = sendSnapButton;
}


- (void)configureInboxButton
{
    Button *inboxButton = [[Button alloc] init];
    [inboxButton setImage:[UIImage imageNamed:@"white-check-box"] forState:UIControlStateNormal];
    inboxButton.translatesAutoresizingMaskIntoConstraints = NO;
    [inboxButton addTarget:self action:@selector(inboxButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:inboxButton];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:inboxButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:inboxButton attribute:NSLayoutAttributeBottom multiplier:1 constant:20];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:inboxButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CheckBoxButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:inboxButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CheckBoxButtonHeight];
    
    [self addConstraint:leftConstraint];
    [self addConstraint:bottomConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    
    self.inboxButton = inboxButton;
}

- (void)configureCancelButton
{
    Button *cancelButton = [[Button alloc] init];
    [cancelButton setImage:[UIImage imageNamed:@"white-x"] forState:UIControlStateNormal];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:cancelButton];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:20];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:20];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CancelButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CancelButtonWidth];
    
    [self addConstraint:leftConstraint];
    [self addConstraint:topConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    
    cancelButton.hidden = YES;
    self.cancelButton = cancelButton;
}

#pragma mark - User Interaction

- (void)cameraButtonPressed
{
    AVCaptureConnection *captureConnection = [self captureConnection];
    
    if (captureConnection == nil) return;
    
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        UIImage *image = [self imageFromSampleBuffer:imageDataSampleBuffer];
        [self.capturedImageView setImage:image];
        self.hasImage = YES;
        if ([self.delegate respondsToSelector:@selector(cameraViewDidExitCaptureMode:)])
        {
            [self.delegate cameraViewDidExitCaptureMode:self];
        }
    }];
}

- (void)flipCameraButtonPressed
{
    [self.captureSession beginConfiguration];
    
    if (self.cameraFlipped)
    {
        [self.captureSession removeInput:self.frontCameraDeviceInput];
        [self.captureSession addInput:self.backCameraDeviceInput];
    }
    else
    {
        [self.captureSession removeInput:self.backCameraDeviceInput];
        [self.captureSession addInput:self.frontCameraDeviceInput];
    }
    
    self.cameraFlipped = !self.cameraFlipped;
    
    [self.captureSession commitConfiguration];
}

- (void)sendSnapButtonPressed
{
    UIImage *image = [self rasterizeViewToImage];
    
    [self.delegate cameraView:self didPressSnapButtonWithImage:image];
}

- (void)inboxButtonPressed
{
    
}

- (void)cancelButtonPressed
{
    self.hasImage = NO;
}

- (void)pickImageButtonPressed
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.delegate cameraView:self didSelectMediaFromImagePickerController:picker];
    
}

- (void)textStyleButtonPressed
{
    [UIView animateWithDuration:.1 animations:^{
        self.textStyleButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }];
    
    [self.snapTextOverlayView textStyleButtonPressed];
}

- (void)textStyleButtonReleased
{
    [UIView animateWithDuration:.1 animations:^{
        self.textStyleButton.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}

#pragma mark - Instance Methods

- (void)startCaptureSession
{
    [self.captureSession startRunning];
    
    if ([self.delegate respondsToSelector:@selector(cameraViewDidEnterCaptureMode:)])
    {
        [self.delegate cameraViewDidEnterCaptureMode:self];
    }
    
}

- (void)stopCaptureSession
{
    [self.captureSession stopRunning];
    
    if ([self.delegate respondsToSelector:@selector(cameraViewDidExitCaptureMode:)])
    {
        [self.delegate cameraViewDidExitCaptureMode:self];
    }
}

- (void)resetToCameraMode
{
    [self setHasImage:NO];
    [self.snapTextOverlayView hide];
}

#pragma mark - Helpers

- (AVCaptureConnection *)captureConnection
{
    AVCaptureConnection *stillImageConnection = nil;
    
    for (AVCaptureConnection *connection in self.captureOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                stillImageConnection = connection;
            }
        }
    }
    
    return stillImageConnection;
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image =  [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}


- (UIImage *)rasterizeViewToImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CALayer *layer = self.snapContainerView.layer;
    [layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setHasImage:(BOOL)hasImage
{
    _hasImage = hasImage;
    [self configureViewForImageState:hasImage];
    
}

- (void)configureViewForImageState:(BOOL)hasImage
{
    if (hasImage)
    {
        self.previewLayer.hidden = YES;
        self.cameraButton.hidden = YES;
        self.flipCameraButton.hidden = YES;
        self.sendSnapButton.hidden = NO;
        self.cancelButton.hidden = NO;
        self.textStyleButton.hidden = NO;
        self.capturedImageView.hidden = NO;
        self.snapTextOverlayView.hidden = NO;
        [self.snapTextOverlayView show];
    }
    else
    {
        self.previewLayer.hidden = NO;
        self.cameraButton.hidden = NO;
        self.flipCameraButton.hidden = NO;
        self.sendSnapButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.textStyleButton.hidden = YES;
        self.capturedImageView.hidden = YES;
        self.snapTextOverlayView.hidden = YES;
        [self.snapTextOverlayView hide];

    }
}

@end
