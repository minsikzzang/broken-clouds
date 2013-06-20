//
//  IFSplashViewControllerIPhone.m
//  broken-clouds
//
//  Created by Min Kim on 6/19/13.
//  Copyright (c) 2013 iFactory Lab, Ltd. All rights reserved.
//

#import "IFSplashViewControllerIPhone.h"
#import "BasicTypes.h"

@interface IFSplashViewControllerIPhone ()

@end

@implementation IFSplashViewControllerIPhone

- (id)init {
  self = [super init];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)dealloc {
  SAFE_RELEASE(badConnectivityView_);
  SAFE_RELEASE(splashView_)
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)setSplash:(UIImage *)portrait andLandscape:(UIImage *)landscape {
  splashView_ = [[UIImageView alloc] initWithImage:portrait];
}

- (void)setSplashNoNetwork:(UIImage *)portrait
              andLandscape:(UIImage *)landscape {
  badConnectivityView_ = [[UIImageView alloc] initWithImage:portrait];
}

- (void)showBadConnectivityView:(BOOL)show  {
  splashView_.hidden = YES;
  if (badConnectivityView_) {
    badConnectivityView_.hidden = NO;
  }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor clearColor];
  
  if (!splashView_) {
    SHOULDNT_BE_REACHED_HERE
  }
  
  CGFloat height = FRH([UIScreen mainScreen].bounds);
  CGFloat y = -20.0;
  
  if ([UIScreen instancesRespondToSelector:@selector(scale)] &&
      [[UIScreen mainScreen] scale] == 2.0) {
    height = 568.0;
    if (FRH([UIScreen mainScreen].bounds) != 568.0) {
      y = -55.0;
    }
  }
  
  splashView_.frame = CGRectMake(0.0, y, 320.0, height);
  splashView_.autoresizingMask = UIViewAutoresizingNone;
  [self.view addSubview:splashView_];
  
  if (badConnectivityView_) {
    badConnectivityView_.frame = CGRectMake(0.0, y, 320.0, height);
    badConnectivityView_.autoresizingMask = UIViewAutoresizingNone;
    badConnectivityView_.hidden = YES;
    [self.view addSubview:badConnectivityView_];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

#pragma mark
#pragma mark - iOS6

- (NSUInteger)supportedInterfaceOrientations {
  if ([UIDevice currentDevice].userInterfaceIdiom ==
      UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskPortrait;
  }
  
  return UIInterfaceOrientationMaskAll;
}

#pragma mark
#pragma mark - iOS5 and older

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  if ([UIDevice currentDevice].userInterfaceIdiom ==
      UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
    return YES;
  }
}

@end
