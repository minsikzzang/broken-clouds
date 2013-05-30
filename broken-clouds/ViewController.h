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
@class WeatherPhotoService;
@class OutlinedLabel;
@class HiddenScrollView;
@class IFLocation;

@interface ViewController : UIViewController<
  UIScrollViewDelegate,
  UINavigationControllerDelegate,
  UIImagePickerControllerDelegate> {
@private
  NSMutableArray *mockups_;
  int currentMockup_;
  NSTimer *refreshTimer_;
  NSTimer *dateTimer_;
  
  // CLLocationManager *locationManager_;
  IFLocation *location_;
  WeatherService *weatherService_;
  WeatherPhotoService *photoService_;
  UIDebugger *debugger_;
  UIPageControl *pageControl_;
  NSDate *threeHourly_;
  NSMutableArray *hours_;
  NSMutableArray *hourlyTemps_;
  NSMutableArray *hourlyWeathers_;
  NSMutableArray *days_;
  NSMutableArray *dailyMaxTemps_;
  NSMutableArray *dailyMinTemps_;
  NSMutableArray *dailyWeathers_;
  UIImagePickerController *cameraUI_;
  
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

- (IBAction)showCamera:(id)sender;


@end
