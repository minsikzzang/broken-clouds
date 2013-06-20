//
//  IFSplashViewController.h
//  broken-clouds
//
//  Created by Min Kim on 6/19/13.
//  Copyright (c) 2013 iFactory Lab, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IFSplashViewConnectivityCheckDelegate<NSObject>

//
// Notify to deleate when connection state is ok.
//
- (void)onConnectivityOK;

//
// Notify to delegate when connection state is bad.
//
- (void)onConnectivityBad;

@end


@class Reachability;

typedef enum {
	SplashView = 0,
	BadConnectionView
} ViewStage;

@interface IFSplashViewController : UIViewController {
@private
  id<IFSplashViewConnectivityCheckDelegate> delegate_;
  NSInteger currentTry_;
  NSInteger retry_;
  double timeout_;
  Reachability *reachability_;
  NSTimer *timer_;
@protected
  ViewStage stage_;
}

//
// Set delegate to retrieve notification of connectivity state
//
@property (nonatomic, retain) id delegate;

//
// Set retry number and timeout. If retry is -1, we retry unlimit amount of
// times
//
- (void)setRetry:(NSInteger)retry timeout:(double)timeout;

- (void)checkAndNotify;

- (void)showBadConnectivityView:(BOOL)show;

- (void)removeFromParentView;

- (void)setSplash:(UIImage *)portrait andLandscape:(UIImage *)landscape;

- (void)setSplashNoNetwork:(UIImage *)portrait andLandscape:(UIImage *)landscape;

@end
