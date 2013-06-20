//
//  IFSplashViewController.m
//  broken-clouds
//
//  Created by Min Kim on 6/19/13.
//  Copyright (c) 2013 iFactory Lab, Ltd. All rights reserved.
//

#import "IFSplashViewController.h"
#import "BasicTypes.h"
#import "Reachability.h"

@interface IFSplashViewController ()

- (void)startTimer;
- (void)stopTimer;

@end

@implementation IFSplashViewController

@synthesize delegate = delegate_;

const NSInteger kDefaultTry = 100;
const CGFloat kDefaultTimeout = 10.0;

- (id)init {
  self = [super init];
  if (self) {
    // Custom initialization
    reachability_ = [[Reachability reachabilityForInternetConnection] retain];
    timer_ = nil;
    stage_ = SplashView;
    delegate_ = nil;
    currentTry_ = 0;
    retry_ = kDefaultTry;
    timeout_ = kDefaultTimeout;
  }
  return self;
}

- (void)dealloc {
  REMOVE_OBSERVER(self, kReachabilityChangedNotification, nil)
  
  [self stopTimer];
  SAFE_RELEASE(delegate_)
  [super dealloc];
}

- (void)setSplash:(UIImage *)portrait andLandscape:(UIImage *)landscape {
  SHOULDNT_BE_REACHED_HERE
}

- (void)setSplashNoNetwork:(UIImage *)portrait
              andLandscape:(UIImage *)landscape {
  SHOULDNT_BE_REACHED_HERE
}

- (void)setRetry:(NSInteger)retry timeout:(double)timeout  {
  retry_ = retry;
  timeout_ = timeout;
}

- (void)showBadConnectivityView:(BOOL)show {
  
}

- (void)reachabilityChanged:(NSNotification* )note {
  NetworkStatus status = [reachability_ currentReachabilityStatus];
  switch (status) {
    case ReachableViaWiFi:
    case ReachableViaWWAN:
      [self stopTimer];
      REMOVE_OBSERVER(self, kReachabilityChangedNotification, nil)
      
      // Notify to delegate we are currently connected with network
      if (delegate_) {
        [delegate_ onConnectivityOK];
      }
      break;
    case NotReachable:
    default:
      break;
  }
}

- (void)onTimer:(NSTimer *)theTimer {
  [self stopTimer];
  
  NetworkStatus status = [reachability_ currentReachabilityStatus];
  switch (status) {
    case ReachableViaWiFi:
    case ReachableViaWWAN:
      // Notify to delegate we are currently connected with network
      if (delegate_) {
        [delegate_ onConnectivityOK];
      }
      break;
    case NotReachable:
    default:
      // Display error message with connectivity error icon on the screen
      [self showBadConnectivityView:YES];
      
      // Notify to delegate that we have not bad connectivity
      if (delegate_) {
        [delegate_ onConnectivityBad];
      }
      // If current try count is less than the given, start another timer
      if (currentTry_ < retry_)
        [self startTimer];
      break;
  }
}

- (void)startTimer {
  START_NSTIMER(timer_, timeout_, onTimer:)
  currentTry_++;
}

- (void)stopTimer {
  STOP_NSTIMER(timer_)
}

- (void)checkAndNotify {
  NetworkStatus status = [reachability_ currentReachabilityStatus];
  switch (status) {
    case ReachableViaWiFi:
    case ReachableViaWWAN:
      // Notify to delegate we are currently connected with network
      if (delegate_) {
        [delegate_ onConnectivityOK];
      }
      break;
    case NotReachable:
    default:
      // If not rechable, start notifier so whenever we get connected we notify
      // to the delegate or wait for timeout and print out error messages
      ADD_OBSERVER(self, reachabilityChanged:, kReachabilityChangedNotification, nil)
      [reachability_ startNotifier];
      [self startTimer];
      break;
  }
}

- (void)removeFromParentView  {
  [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [self stopTimer];
}

@end

