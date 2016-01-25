//
//  CameraView.m
//  Feed
//
//  Created by Adam on 1/19/16.
//  Copyright © 2016 ;. All rights reserved.
//

#import "CameraView.h"

static NSInteger ButtonMargin = 20;
static NSInteger CameraButtonHeight = 80;
static NSInteger FlipCameraButtonHeight = 40;
static NSInteger CheckBoxButtonHeight = 45;
static NSInteger CancelButtonHeight = 30;
static NSInteger CancelButtonWidth = 30;


@interface CameraView()

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureConnection *captureConnection;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) UIImageView *capturedImageView;
@property (strong, nonatomic) CameraButton *cameraButton;
@property (strong, nonatomic) UIButton *flipCameraButton;
@property (strong, nonatomic) UIButton *sendSnapButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *inboxButton;


@property (nonatomic) BOOL hasImage;

@end

@implementation CameraView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureCaptureSession];
    [self configureCameraView];
    [self configureCameraButton];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self configureCaptureSession];
        [self configureCameraView];
        [self configureImageView];
        [self configureCameraButton];
        [self configureFlipCameraButton];
        [self configureSendSnapButton];
        [self configureInboxButton];
        [self configureCancelButton];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.previewLayer.frame = self.bounds;
}

#pragma mark  - Setup

- (void)configureCaptureSession
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (deviceInput == nil)
    {
        NSLog(@"%@", error);
        return;
    }
    
    if (![captureSession canAddInput:deviceInput])
    {
        NSLog(@"Couldn't add input");
        return;
    }
    
    [captureSession addInput:deviceInput];
    
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

- (void)configureImageView
{
    self.capturedImageView = [[UIImageView alloc] init];
    self.capturedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.capturedImageView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.capturedImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self addConstraint:topConstraint];
    [self addConstraint:bottomConstraint];
    [self addConstraint:leftConstraint];
    [self addConstraint:rightConstraint];
    [self addConstraint:heightConstraint];
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
    [self addConstraint:centerConstraint];
    [self addConstraint:bottomConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
}

- (void)configureFlipCameraButton
{
    UIButton *flipCameraButton = [[UIButton alloc] init];
    [flipCameraButton setImage:[UIImage imageNamed:@"flip-camera-icon"] forState:UIControlStateNormal];
    flipCameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    [flipCameraButton addTarget:self action:@selector(flipCameraButton) forControlEvents:UIControlEventTouchUpInside];
    [flipCameraButton layoutIfNeeded];
    
    [self addSubview:flipCameraButton];
    
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:flipCameraButton attribute:NSLayoutAttributeRight multiplier:1 constant:ButtonMargin];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FlipCameraButtonHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:flipCameraButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FlipCameraButtonHeight];
    
    
    self.flipCameraButton = flipCameraButton;
    self.flipCameraButton.hidden = NO;
    
    [self addConstraint:rightConstraint];
    [self addConstraint:topConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
}

- (void)configureSendSnapButton
{
    UIButton *sendSnapButton = [[UIButton alloc] init];
    [sendSnapButton setImage:[UIImage imageNamed:@"white-angle-arrow"] forState:UIControlStateNormal];
    sendSnapButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendSnapButton addTarget:self action:@selector(sendSnapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:sendSnapButton];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:sendSnapButton attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:sendSnapButton attribute:NSLayoutAttributeBottom multiplier:1 constant:ButtonMargin];
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
    UIButton *inboxButton = [[UIButton alloc] init];
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
    UIButton *cancelButton = [[UIButton alloc] init];
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
    
    self.image = nil;
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        UIImage *image = [self imageFromSampleBuffer:imageDataSampleBuffer];
        
        [self.delegate cameraView:self didCaptureImage:image];
        [self setImage:image];
        self.hasImage = YES;
        
        if ([self.delegate respondsToSelector:@selector(cameraViewDidExitCaptureMode:)])
        {
            [self.delegate cameraViewDidExitCaptureMode:self];
        }
    }];
}

- (void)sendSnapButtonPressed
{
    [self.delegate cameraViewSendSnapButtonPressed:self];
}

- (void)inboxButtonPressed
{
    
}

- (void)cancelButtonPressed
{
    [self setImage:nil];
    self.hasImage = NO;
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

- (void)setImage:(UIImage *)image
{
    _image = image;
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
        self.sendSnapButton.hidden = NO;
        self.cancelButton.hidden = NO;
        self.capturedImageView.hidden = NO;
        [self.capturedImageView setImage:self.image];
    }
    else
    {
        self.previewLayer.hidden = NO;
        self.cameraButton.hidden = NO;
        self.flipCameraButton.hidden = NO;
        self.sendSnapButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.capturedImageView.hidden = YES;
    }
}

@end
