//
//  IFSplashViewControllerIPad.m
//  broken-clouds
//
//  Created by Min Kim on 6/19/13.
//  Copyright (c) 2013 iFactory Lab, Ltd. All rights reserved.
//

#import "IFSplashViewControllerIPad.h"
#import "BasicTypes.h"

@interface IFSplashViewControllerIPad ()

@end

@implementation IFSplashViewControllerIPad

- (id)init {
  self = [super init];
  if (self) {
    // Custom initialization
    splashView_ =
    [[UIImageView alloc]
     initWithImage:[UIImage imageNamed:@"ipad_splash.png"]];
    splashLandscapeView_ =
    [[UIImageView alloc]
     initWithImage:[UIImage imageNamed:@"ipad_splash_landscape.png"]];
    badConnectivityView_ =
    [[UIImageView alloc]
     initWithImage:[UIImage imageNamed:@"ipad_bad_connectivity"]];
    badConnectivityLandscapeView_ =
    [[UIImageView alloc]
     initWithImage:[UIImage imageNamed:@"ipad_bad_connectivity_landscape"]];
    
    self.view.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)dealloc {
  SAFE_RELEASE(badConnectivityView_)
  SAFE_RELEASE(badConnectivityLandscapeView_)
  SAFE_RELEASE(splashView_)
  SAFE_RELEASE(splashLandscapeView_)
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)showBadConnectivityView:(BOOL)show {
  if (stage_ == SplashView) {
    splashView_.hidden = YES;
    splashLandscapeView_.hidden = YES;
    
    switch (self.interfaceOrientation) {
      case UIInterfaceOrientationLandscapeLeft:
      case UIInterfaceOrientationLandscapeRight:
        badConnectivityLandscapeView_.hidden = NO;
        badConnectivityView_.hidden = YES;
        break;
      default:
        badConnectivityLandscapeView_.hidden = YES;
        badConnectivityView_.hidden = NO;
        break;
    }
    stage_ = BadConnectionView;
  }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Do any additional setup after loading the view from its nib.
  splashView_.autoresizingMask = UIViewAutoresizingNone;
  badConnectivityView_.autoresizingMask = UIViewAutoresizingNone;
  splashLandscapeView_.autoresizingMask = UIViewAutoresizingNone;
  badConnectivityLandscapeView_.autoresizingMask = UIViewAutoresizingNone;
  
  splashView_.frame =
  CGRectMake(0.0, 0.0, FRW(splashView_.frame), FRH(splashView_.frame));
  badConnectivityView_.frame = CGRectMake(0.0, 0.0,
                                          FRW(badConnectivityView_.frame),
                                          FRH(badConnectivityView_.frame));
  
  [self.view addSubview:splashView_];
  [self.view addSubview:splashLandscapeView_];
  [self.view addSubview:badConnectivityLandscapeView_];
  [self.view addSubview:badConnectivityView_];
  
  NSLog(@"%@", badConnectivityView_);
  
  badConnectivityLandscapeView_.hidden = YES;
  badConnectivityView_.hidden = YES;
  
  switch (self.interfaceOrientation) {
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      splashView_.hidden = YES;
      break;
    default:
      splashLandscapeView_.hidden = YES;
      break;
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    return YES;
  } else {
    if (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
      return YES;
    }
    return NO;
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
      toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
    if (stage_ == SplashView) {
      splashLandscapeView_.hidden = YES;
      splashView_.hidden = NO;
    } else {
      badConnectivityLandscapeView_.hidden = YES;
      badConnectivityView_.hidden = NO;
    }
  } else {
    if (stage_ == SplashView) {
      splashLandscapeView_.hidden = NO;
      splashView_.hidden = YES;
    } else {
      badConnectivityLandscapeView_.hidden = NO;
      badConnectivityView_.hidden = YES;
    }
  }
}

@end
