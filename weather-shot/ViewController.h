//
//  ViewController.h
//  weather-shot
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIDebugger;
@class WeatherService;

@interface ViewController : UIViewController<CLLocationManagerDelegate, UIScrollViewDelegate> {
@private
  NSMutableArray *mockups_;
  int currentMockup_;
  // UIImageView *mockupView_;
  NSTimer *refreshTimer_;
  CLLocationManager *locationManager_;
  WeatherService *weatherService_;
  UIDebugger *debugger_;

  IBOutlet UILabel *tempView_;
  IBOutlet UILabel *locationView_;
  IBOutlet UILabel *descriptionView_;
  IBOutlet UIImageView *imageView_;
  IBOutlet UIView *debugView_;
  IBOutlet UIScrollView *hiddenLayerView_;
}

@end
