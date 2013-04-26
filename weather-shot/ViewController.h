//
//  ViewController.h
//  weather-shot
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeatherService;

@interface ViewController : UIViewController<CLLocationManagerDelegate> {
@private
  NSMutableArray *mockups_;
  int currentMockup_;
  UIImageView *mockupView_;
  NSTimer *refreshTimer_;
  CLLocationManager *locationManager_;
  WeatherService *weatherService_;
  UILabel *tempView_;
  UILabel *locationView_;
}

@end
