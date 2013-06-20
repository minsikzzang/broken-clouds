//
//  IFImagePickerController.h
//  broken-clouds
//
//  Created by Min Kim on 6/8/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "BlurOverlayView.h"

static NSString *const IFImagePickerImageSource = @"IFImageSource";
static NSString *const IFImagePickerImageLibrary = @"IFImageLibrary";
static NSString *const IFImagePickerImageCamera = @"IFImageCamera";

@class IFImagePickerController;

@protocol IFImagePickerDelegate <NSObject>
@optional

- (void)imagePickerController:(IFImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(IFImagePickerController *)picker;

@end


@interface IFImagePickerController : UIViewController<
    UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
  GPUImageStillCamera *stillCamera_;
  GPUImageOutput<GPUImageInput> *filter_;
  GPUImageOutput<GPUImageInput> *blurFilter_;
  GPUImageCropFilter *cropFilter_;
  GPUImagePicture *staticPicture_;
  NSURL *staticPictureURL_;
  UIImageOrientation staticPictureOriginalOrientation_;
  BOOL fromLibrary_;
}

@property (nonatomic, retain) IBOutlet GPUImageView *imageView;
@property (nonatomic, retain) id <IFImagePickerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *blurToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *filtersToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *retakeButton;

@property (nonatomic, retain) IBOutlet UIScrollView *filterScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *filtersBackgroundImageView;
@property (nonatomic, retain) IBOutlet UIView *photoBar;
@property (nonatomic, retain) IBOutlet UIView *topBar;

@property (nonatomic, retain) BlurOverlayView *blurOverlayView;
@property (nonatomic, retain) UIImageView *focusView;
@property (nonatomic, assign) CGFloat outputJPEGQuality;

- (IBAction)handlePan:(UIGestureRecognizer *)sender;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)handleTabToFocus:(UITapGestureRecognizer *)sender;
- (IBAction)retakePhoto:(id)sender;
- (IBAction)switchToLibrary:(id)sender;
- (IBAction)toggleFlash:(UIButton *)sender;
- (IBAction)toggleBlur:(UIButton *)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)toggleFilters:(UIButton *)sender;

@end
