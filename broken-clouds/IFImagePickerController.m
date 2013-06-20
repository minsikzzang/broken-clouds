//
//  IFImagePickerController.m
//  broken-clouds
//
//  Created by Min Kim on 6/8/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "IFImagePickerController.h"
#import "BasicTypes.h"
#import "GrayscaleContrastFilter.h"

const CGFloat kStaticBlurSize = 2.0f;
const int kMaxFilterSize = 10;

@interface IFImagePickerController ()

- (void)loadFilters;
- (void)setUpCamera;
- (void)prepareFilter;
- (void)prepareLiveFilter;
- (void)prepareStaticFilter;
- (void)removeAllTargets;
- (void)showFilters;
- (void)hideFilters;
- (void)filterClicked:(UIButton *)sender;
- (void)setFilter:(int)index;
- (void)prepareForCapture;
- (void)captureImage;
- (void)showBlurOverlay:(BOOL)show;
- (void)flashBlurOverlay;

@end

@implementation IFImagePickerController

BOOL isStatic_;
BOOL hasBlur_;
int selectedFilter_;

@synthesize delegate;
@synthesize imageView;
@synthesize cameraToggleButton;
@synthesize photoCaptureButton;
@synthesize blurToggleButton;
@synthesize flashToggleButton;
@synthesize cancelButton;
@synthesize retakeButton;
@synthesize filtersToggleButton;
@synthesize libraryToggleButton;
@synthesize filterScrollView;
@synthesize filtersBackgroundImageView;
@synthesize photoBar;
@synthesize topBar;
@synthesize blurOverlayView;
@synthesize outputJPEGQuality;

- (id)init {
  self = [super init];
  if (self) {
    self.outputJPEGQuality = 1.0;
    fromLibrary_ = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.wantsFullScreenLayout = YES;
  
  // set background color
  self.view.backgroundColor = [UIColor colorWithPatternImage:
                               [UIImage imageNamed:@"micro_carbon"]];
  
  self.photoBar.backgroundColor = [UIColor colorWithPatternImage:
                                   [UIImage imageNamed:@"photo_bar"]];
  
  self.topBar.backgroundColor = [UIColor colorWithPatternImage:
                                 [UIImage imageNamed:@"photo_bar"]];
  // button states
  [self.blurToggleButton setSelected:NO];
  [self.filtersToggleButton setSelected:NO];
  
  staticPictureOriginalOrientation_ = UIImageOrientationUp;
  
  self.focusView = [[[UIImageView alloc]
                     initWithImage:[UIImage imageNamed:@"focus-crosshair"]]
                    autorelease];
	[self.view addSubview:self.focusView];
	self.focusView.alpha = 0;

  self.blurOverlayView =
    [[[BlurOverlayView alloc] initWithFrame:CGRectMake(0, 0,
                                                      self.imageView.frame.size.width,
                                                      self.imageView.frame.size.height)] autorelease];
  self.blurOverlayView.alpha = 0;
  [self.imageView addSubview:self.blurOverlayView];
  
  hasBlur_ = NO;
  isStatic_ = NO;

  [self loadFilters];
  
  SAFE_RELEASE(cropFilter_)
  // we need a crop filter for the live video
  cropFilter_ = [[GPUImageCropFilter alloc]
                initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 0.75f)];
  
  SAFE_RELEASE(filter_)
  filter_ = [[GPUImageFilter alloc] init];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [self setUpCamera];
  });
}

- (void)loadFilters {
  for (int i = 0; i < kMaxFilterSize; i++) {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i + 1]]
                      forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0 + i * (60 + 10), 5.0f, 60.0f, 60.0f);
    button.layer.cornerRadius = 7.0f;
    
    // use bezier path instead of maskToBounds on button.layer
    UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:CGSizeMake(7.0, 7.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = button.bounds;
    maskLayer.path = bi.CGPath;
    button.layer.mask = maskLayer;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [button addTarget:self
               action:@selector(filterClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    button.tag = i;
    [button setTitle:@"*" forState:UIControlStateSelected];
    if (i == 0){
      [button setSelected:YES];
    }
    
		[self.filterScrollView addSubview:button];
	}
  
	[self.filterScrollView setContentSize:
   CGSizeMake(10 + kMaxFilterSize * (60 + 10), 75.0)];
}

- (void)setUpCamera {  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    // Has camera    
    stillCamera_ = [[GPUImageStillCamera alloc]
                    initWithSessionPreset:AVCaptureSessionPresetPhoto
                    cameraPosition:AVCaptureDevicePositionBack];
    
    stillCamera_.outputImageOrientation = UIInterfaceOrientationPortrait;
    runOnMainQueueWithoutDeadlocking(^{
      [stillCamera_ startCameraCapture];
      if([stillCamera_.inputCamera hasTorch]){
        [self.flashToggleButton setEnabled:YES];
      }else{
        [self.flashToggleButton setEnabled:NO];
      }
      [self prepareFilter];
    });
  } else {
    // No camera
    NSLog(@"No camera");
    runOnMainQueueWithoutDeadlocking(^{
      [self prepareFilter];
    });
  }  
}

- (void)filterClicked:(UIButton *) sender {
  for(UIView *view in self.filterScrollView.subviews){
    if([view isKindOfClass:[UIButton class]]){
      [(UIButton *)view setSelected:NO];
    }
  }
  
  [sender setSelected:YES];
  [self removeAllTargets];
  
  selectedFilter_ = sender.tag;
  [self setFilter:sender.tag];
  [self prepareFilter];
}

- (void)setFilter:(int)index {
  SAFE_RELEASE(filter_)
  switch (index) {
    case 1:{
      filter_ = [[GPUImageContrastFilter alloc] init];
      [(GPUImageContrastFilter *)filter_ setContrast:1.75];
    } break;
    case 2: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess"];
    } break;
    case 3: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"02"];
    } break;
    case 4: {
      filter_ = [[GrayscaleContrastFilter alloc] init];
    } break;
    case 5: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"17"];
    } break;
    case 6: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"aqua"];
    } break;
    case 7: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"yellow-red"];
    } break;
    case 8: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"06"];
    } break;
    case 9: {
      filter_ = [[GPUImageToneCurveFilter alloc] initWithACV:@"purple-green"];
    } break;
    default:
      filter_ = [[GPUImageFilter alloc] init];
      break;
  }
}

- (void)prepareFilter {
  if (![UIImagePickerController
        isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    isStatic_ = YES;
  }
  
  if (!isStatic_) {
    [self prepareLiveFilter];
  } else {
    [self prepareStaticFilter];
  }
}

- (void)prepareLiveFilter {
  [stillCamera_ addTarget:cropFilter_];
  [cropFilter_ addTarget:filter_];
  
  // Blur is terminal filter
  if (hasBlur_) {
    [filter_ addTarget:blurFilter_];
    [blurFilter_ addTarget:self.imageView];
    // Regular filter is terminal
  } else {
    [filter_ addTarget:self.imageView];
  }
  
  [filter_ prepareForImageCapture];
}

- (void)prepareStaticFilter {
  if (!staticPicture_) {
    // TODO: fix this hack
    [self performSelector:@selector(switchToLibrary:) withObject:nil afterDelay:0.5];
  }
  
  [staticPicture_ addTarget:filter_];
  
  // Blur is terminal filter
  if (hasBlur_) {
    [filter_ addTarget:blurFilter_];
    [blurFilter_ addTarget:self.imageView];
    // regular filter is terminal
  } else {
    [filter_ addTarget:self.imageView];
  }
  
  GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
  switch (staticPictureOriginalOrientation_) {
    case UIImageOrientationLeft:
      imageViewRotationMode = kGPUImageRotateLeft;
      break;
    case UIImageOrientationRight:
      imageViewRotationMode = kGPUImageRotateRight;
      break;
    case UIImageOrientationDown:
      imageViewRotationMode = kGPUImageRotate180;
      break;
    default:
      imageViewRotationMode = kGPUImageNoRotation;
      break;
  }
  
  // seems like atIndex is ignored by GPUImageView...
  [self.imageView setInputRotation:imageViewRotationMode atIndex:0];
  [staticPicture_ processImage];  
}

- (void)showFilters {
  [self.filtersToggleButton setSelected:YES];
  self.filtersToggleButton.enabled = NO;
  CGRect imageRect = self.imageView.frame;
  imageRect.origin.y -= 34;
  CGRect sliderScrollFrame = self.filterScrollView.frame;
  sliderScrollFrame.origin.y -= self.filterScrollView.frame.size.height;
  CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
  sliderScrollFrameBackground.origin.y -=
    self.filtersBackgroundImageView.frame.size.height - 3;
  
  self.filterScrollView.hidden = NO;
  self.filtersBackgroundImageView.hidden = NO;
  [UIView animateWithDuration:0.10
                        delay:0.05
                      options:UIViewAnimationOptionCurveEaseOut 
                   animations:^{
                     self.imageView.frame = imageRect;
                     self.filterScrollView.frame = sliderScrollFrame;
                     self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                   }
                   completion:^(BOOL finished){
                     self.filtersToggleButton.enabled = YES;
                   }];
}

- (void)hideFilters {
  [self.filtersToggleButton setSelected:NO];
  CGRect imageRect = self.imageView.frame;
  imageRect.origin.y += 34.0;
  CGRect sliderScrollFrame = self.filterScrollView.frame;
  sliderScrollFrame.origin.y += self.filterScrollView.frame.size.height;
  
  CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
  sliderScrollFrameBackground.origin.y += self.filtersBackgroundImageView.frame.size.height-3;
  
  [UIView animateWithDuration:0.10
                        delay:0.05
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.imageView.frame = imageRect;
                     self.filterScrollView.frame = sliderScrollFrame;
                     self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                   }
                   completion:^(BOOL finished){
                     self.filtersToggleButton.enabled = YES;
                     self.filterScrollView.hidden = YES;
                     self.filtersBackgroundImageView.hidden = YES;
                   }];
}

- (void)removeAllTargets {
  [stillCamera_ removeAllTargets];
  [staticPicture_ removeAllTargets];
  [cropFilter_ removeAllTargets];
  
  // regular filter
  [filter_ removeAllTargets];
  
  // blur
  [blurFilter_ removeAllTargets];
}

- (IBAction)handlePan:(id)sender {
  if (hasBlur_) {
    CGPoint tapPoint = [sender locationInView:imageView];
    GPUImageGaussianSelectiveBlurFilter *gpu =
      (GPUImageGaussianSelectiveBlurFilter*)blurFilter_;
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
      [self showBlurOverlay:YES];
      [gpu setBlurSize:0.0f];
      if (isStatic_) {
        [staticPicture_ processImage];
      }
    }
    
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
      [gpu setBlurSize:0.0f];
      [self.blurOverlayView setCircleCenter:tapPoint];
      [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
      [gpu setBlurSize:kStaticBlurSize];
      [self showBlurOverlay:NO];
      if (isStatic_) {
        [staticPicture_ processImage];
      }
    }
  }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender {
  if (hasBlur_) {
    CGPoint midpoint = [sender locationInView:imageView];
    GPUImageGaussianSelectiveBlurFilter *gpu =
      (GPUImageGaussianSelectiveBlurFilter *)blurFilter_;
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
      [self showBlurOverlay:YES];
      [gpu setBlurSize:0.0f];
      if (isStatic_) {
        [staticPicture_ processImage];
      }
    }
    
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
      [gpu setBlurSize:0.0f];
      [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
      self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
      CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
      self.blurOverlayView.radius = radius*320.f;
      [gpu setExcludeCircleRadius:radius];
      sender.scale = 1.0f;
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
      [gpu setBlurSize:kStaticBlurSize];
      [self showBlurOverlay:NO];
      if (isStatic_) {
        [staticPicture_ processImage];
      }
    }
  }
}

- (IBAction)handleTabToFocus:(UITapGestureRecognizer *)tgr {
  if (!isStatic_ && tgr.state == UIGestureRecognizerStateRecognized) {
		CGPoint location = [tgr locationInView:self.imageView];
		AVCaptureDevice *device = stillCamera_.inputCamera;
		CGPoint pointOfInterest = CGPointMake(.5f, .5f);
		CGSize frameSize = [[self imageView] frame].size;
		if ([stillCamera_ cameraPosition] == AVCaptureDevicePositionFront) {
      location.x = frameSize.width - location.x;
		}
		pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
		if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
      NSError *error;
      if ([device lockForConfiguration:&error]) {
        [device setFocusPointOfInterest:pointOfInterest];
        
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
        
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
          [device setExposurePointOfInterest:pointOfInterest];
          [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        self.focusView.center = [tgr locationInView:self.view];
        self.focusView.alpha = 1;
        
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
          self.focusView.alpha = 0;
        } completion:nil];
        
        [device unlockForConfiguration];
			} else {
        NSLog(@"ERROR = %@", error);
			}
		}
	}
}

- (IBAction)retakePhoto:(id)sender {
  [self.retakeButton setHidden:YES];
  [self.libraryToggleButton setHidden:NO];
  SAFE_RELEASE(staticPicture_)

  staticPictureOriginalOrientation_ = UIImageOrientationUp;
  isStatic_ = NO;
  [self removeAllTargets];
  [stillCamera_ startCameraCapture];
  [self.cameraToggleButton setEnabled:YES];
  
  if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]
     && stillCamera_
     && [stillCamera_.inputCamera hasTorch]) {
    [self.flashToggleButton setEnabled:YES];
  }
  
  [self.photoCaptureButton setImage:[UIImage imageNamed:@"camera-icon2"]
                           forState:UIControlStateNormal];
  [self.photoCaptureButton setTitle:nil forState:UIControlStateNormal];
  
  if ([self.filtersToggleButton isSelected]) {
    [self hideFilters];
  }
  
  [self setFilter:selectedFilter_];
  [self prepareFilter];
}

- (IBAction)switchToLibrary:(id)sender {
  if (!isStatic_) {
    // shut down camera
    [stillCamera_ stopCameraCapture];
    [self removeAllTargets];
  }
  
  if ([self.filtersToggleButton isSelected]) {
    [self hideFilters];
  }
  
  UIImagePickerController* imagePickerController =
    [[[UIImagePickerController alloc] init] autorelease];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  imagePickerController.delegate = self;
  imagePickerController.allowsEditing = YES;
  [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (IBAction)toggleFlash:(UIButton *)button {
  [button setSelected:!button.selected];
}

- (IBAction)toggleBlur:(UIButton *)sender {
  [self.blurToggleButton setEnabled:NO];
  [self removeAllTargets];

  if (hasBlur_) {
    hasBlur_ = NO;
    [self showBlurOverlay:NO];
    [self.blurToggleButton setSelected:NO];
  } else {
    if (!blurFilter_) {
      blurFilter_ = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
      [(GPUImageGaussianSelectiveBlurFilter *)blurFilter_ setExcludeCircleRadius:80.0/320.0];
      [(GPUImageGaussianSelectiveBlurFilter *)blurFilter_ setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
      [(GPUImageGaussianSelectiveBlurFilter *)blurFilter_ setBlurSize:kStaticBlurSize];
      [(GPUImageGaussianSelectiveBlurFilter *)blurFilter_ setAspectRatio:1.0f];
    }
    hasBlur_ = YES;
    [self.blurToggleButton setSelected:YES];
    [self flashBlurOverlay];
  }
  
  [self prepareFilter];
  [self.blurToggleButton setEnabled:YES];
}

- (IBAction)toggleFilters:(UIButton *)sender {
  sender.enabled = NO;
  if (sender.selected){
    [self hideFilters];
  } else {
    [self showFilters];
  }  
}

- (void)showBlurOverlay:(BOOL)show {
  if (show){
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
      self.blurOverlayView.alpha = 0.6;
    } completion:^(BOOL finished) {
      
    }];
  } else{
    [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
      self.blurOverlayView.alpha = 0;
    } completion:^(BOOL finished) {
      
    }];
  }
}

- (void)flashBlurOverlay {
  [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
    self.blurOverlayView.alpha = 0.6;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
      self.blurOverlayView.alpha = 0;
    } completion:^(BOOL finished) {
      
    }];
  }];
}

- (IBAction)switchCamera:(id)sender {
  [self.cameraToggleButton setEnabled:NO];
  [stillCamera_ rotateCamera];
  [self.cameraToggleButton setEnabled:YES];
  
  if ([UIImagePickerController isSourceTypeAvailable:
       UIImagePickerControllerSourceTypeCamera] && stillCamera_) {
    if ([stillCamera_.inputCamera hasFlash] && [stillCamera_.inputCamera hasTorch]) {
      [self.flashToggleButton setEnabled:YES];
    } else {
      [self.flashToggleButton setEnabled:NO];
    }
  }
}

- (IBAction)cancel:(id)sender {
  [self.delegate imagePickerControllerDidCancel:self];
}

- (IBAction)takePhoto:(id)sender {
  [self.photoCaptureButton setEnabled:NO];
  
  if (!isStatic_) {
    isStatic_ = YES;
    
    [self.libraryToggleButton setHidden:YES];
    [self.cameraToggleButton setEnabled:NO];
    [self.flashToggleButton setEnabled:NO];
    [self prepareForCapture];
  } else {
    GPUImageOutput<GPUImageInput> *processUpTo;    
    if (hasBlur_) {
      processUpTo = blurFilter_;
    } else {
      processUpTo = filter_;
    }
    
    [staticPicture_ processImage];
    
    UIImage *currentFilteredVideoFrame =
      [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation_];
    
    NSMutableDictionary *info = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          UIImageJPEGRepresentation(currentFilteredVideoFrame,self.outputJPEGQuality),
                          @"data",
                          currentFilteredVideoFrame,
                          UIImagePickerControllerEditedImage,
                          staticPictureURL_,
                          UIImagePickerControllerReferenceURL,
                          nil] autorelease];
    [info setObject:(fromLibrary_ ? IFImagePickerImageLibrary : IFImagePickerImageCamera)
             forKey:IFImagePickerImageSource];
    
    [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];    
  }
}

- (void)prepareForCapture {
  [stillCamera_.inputCamera lockForConfiguration:nil];
  if (self.flashToggleButton.selected && [stillCamera_.inputCamera hasTorch]) {
    [stillCamera_.inputCamera setTorchMode:AVCaptureTorchModeOn];
    [self performSelector:@selector(captureImage)
               withObject:nil
               afterDelay:0.25];
  } else{
    [self captureImage];
  }
}

- (void)captureImage {
  UIImage *img = [cropFilter_ imageFromCurrentlyProcessedOutput];
  [stillCamera_.inputCamera unlockForConfiguration];
  [stillCamera_ stopCameraCapture];
  [self removeAllTargets];
  fromLibrary_ = NO;
  
  staticPicture_ = [[GPUImagePicture alloc] initWithImage:img
                                      smoothlyScaleOutput:YES];
  staticPictureOriginalOrientation_ = img.imageOrientation;
  
  [self prepareFilter];
  [self.retakeButton setHidden:NO];
  [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
  [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
  [self.photoCaptureButton setEnabled:YES];
  if (![self.filtersToggleButton isSelected]){
    [self showFilters];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [self removeAllTargets];
  SAFE_RELEASE(staticPictureURL_)
  SAFE_RELEASE(stillCamera_)
  SAFE_RELEASE(cropFilter_)
  SAFE_RELEASE(filter_)
  SAFE_RELEASE(blurFilter_)
  SAFE_RELEASE(staticPicture_)
  [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
  [stillCamera_ stopCameraCapture];
  [super viewWillDisappear:animated];
}

#pragma mark
#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {  
  UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
  if (outputImage == nil) {
    outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
  }
  staticPictureURL_ = [[info objectForKey:UIImagePickerControllerReferenceURL] retain];
  fromLibrary_ = YES;
  
  if (outputImage) {
    staticPicture_ = [[GPUImagePicture alloc] initWithImage:outputImage
                                        smoothlyScaleOutput:YES];
    staticPictureOriginalOrientation_ = outputImage.imageOrientation;
    isStatic_ = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.cameraToggleButton setEnabled:NO];
    [self.flashToggleButton setEnabled:NO];
    [self prepareStaticFilter];
    [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
    [self.photoCaptureButton setEnabled:YES];
    
    if (![self.filtersToggleButton isSelected]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showFilters];
      });
    }
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  if (isStatic_) {
    // TODO: fix this hack
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.delegate imagePickerControllerDidCancel:self];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self retakePhoto:nil];
  }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

#endif

@end
