//
//  IFSplashViewControllerIPad.h
//  broken-clouds
//
//  Created by Min Kim on 6/19/13.
//  Copyright (c) 2013 iFactory Lab, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFSplashViewController.h"

@interface IFSplashViewControllerIPad : IFSplashViewController {
@private
  UIImageView *splashView_;
  UIImageView *badConnectivityView_;
  UIImageView *splashLandscapeView_;
  UIImageView *badConnectivityLandscapeView_;
}

@end
