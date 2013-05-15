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
@class OutlinedLabel;
@class HiddenScrollView;

@interface ViewController : UIViewController<CLLocationManagerDelegate, UIScrollViewDelegate> {
@private
  NSMutableArray *mockups_;
  int currentMockup_;
  NSTimer *refreshTimer_;
  NSTimer *dateTimer_;
  CLLocationManager *locationManager_;
  WeatherService *weatherService_;
  UIDebugger *debugger_;
  UIPageControl *pageControl_;
  NSDate *threeHourly_;
  NSMutableArray *hours_;
  NSMutableArray *hourlyTemps_;
  NSMutableArray *hourlyWeathers_;
  
  IBOutlet UILabel *tempView_;
  IBOutlet UILabel *locationView_;
  IBOutlet UILabel *descriptionView_;
  IBOutlet OutlinedLabel *dateView_;
  IBOutlet UIImageView *imageView_;
  IBOutlet UIImageView *iconView_;
  IBOutlet UIView *debugView_;
  IBOutlet UIScrollView *hiddenLayerView_;
  IBOutlet UIScrollView *hourlyWeatherView_;
}

@end
