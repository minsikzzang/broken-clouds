//
//  ViewController.m
//  weather-shot
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "ViewController.h"

#import "BasicTypes.h"
#include <math.h>
#import "OutlinedLabel.h"
#import "UIDebugger.h"
#import "Weather.h"
#import "WeatherIconFactory.h"
#import "WeatherService.h"

static NSString *const kMockupName = @"mockup%d.png";
const int kMockupNum = 17;
const int kMockupRefresh = 5;
const int kSecond = 1;


@interface ViewController ()

- (UIImage *)getCurrentMockup;
- (void)refreshScreen;
- (void)updateDate;

@end

@implementation ViewController

- (UIImage *)getCurrentMockup {
  @synchronized (self) {
    if (mockups_.count <= currentMockup_) {
      currentMockup_ = 0;
    }
    return [mockups_ objectAtIndex:currentMockup_++];
  }  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
	// Initialize location manager to get current location data
  weatherService_ = [[WeatherService alloc] init];
  
  debugger_ = [[UIDebugger alloc] init];
  debugger_.parent = debugView_;
  [debugger_ attach];
  
  locationManager_ = [[CLLocationManager alloc] init];
  locationManager_.delegate = self;
  [locationManager_ startUpdatingLocation];
  
  // Load all mockup images and start timer to display in roundrobin way.
  mockups_ = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < kMockupNum; ++i) {
    NSString *mockup = [NSString stringWithFormat:kMockupName, i + 1];
    [mockups_ addObject:[UIImage imageNamed:mockup]];
  }

  // Display first image and start timer
  currentMockup_ = 0;
  [imageView_ setImage:[self getCurrentMockup]];
    
  hiddenLayerView_.delegate = self;
  hiddenLayerView_.contentSize = CGSizeMake(320.0, 578.0);
  [hiddenLayerView_ addSubview:tempView_];
  
  // Initialize and start mockup refrsh timer
  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
  
  // Initialize and start date timer
  START_NSTIMER_(dateTimer_, kSecond, updateDate, YES)
}

- (void)refreshScreen {
  STOP_NSTIMER(refreshTimer_)
  [imageView_ setImage:[self getCurrentMockup]];
  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
}

- (void)updateDate {
  NSDateFormatter *timeFormat = [[[NSDateFormatter alloc] init] autorelease];
  [timeFormat setDateFormat:@"EEEE hh:mm:ss a"];
  timeFormat.locale =
    [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
  NSDate *now = [[[NSDate alloc] init] autorelease];
  dateView_.textColor = [UIColor blackColor];
  dateView_.text =
    [NSString stringWithFormat:@"%@", [timeFormat stringFromDate:now]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  STOP_NSTIMER(refreshTimer_)
}

- (void)dealloc {
  STOP_NSTIMER(dateTimer_)
  STOP_NSTIMER(refreshTimer_)
  SAFE_RELEASE(debugView_)
  SAFE_RELEASE(locationManager_)
  SAFE_RELEASE(tempView_)
  SAFE_RELEASE(locationView_)
  SAFE_RELEASE(mockups_)
  SAFE_RELEASE(weatherService_)
  [super dealloc];
}

#pragma mark -
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  CLLocationCoordinate2D coord = newLocation.coordinate;
  
  [debugger_ debug:[NSString stringWithFormat:@"Retrieved new location coord(%f, %f)",
                    coord.latitude,
                    coord.longitude]];
  
  [weatherService_ getWeatherByCoord:coord.latitude
                           longitude:coord.longitude
                             success:^(Weather *weather) {
                               [debugger_ debug:[NSString stringWithFormat:
                                                 @"name:%@, temp:%@, desc:%@, id:%@",
                                                 weather.name,
                                                 weather.temp,
                                                 weather.desc,
                                                 weather.weatherId]];

                               dispatch_async(dispatch_get_main_queue(), ^{
                                 WeatherIconFactory *factory =
                                  [WeatherIconFactory buildFactory:weather
                                                               lat:coord.latitude
                                                               lng:coord.longitude
                                                               now:[NSDate date]];
                                 iconView_.image = [factory build];
                                 locationView_.text = [weather.name uppercaseString];
                                 tempView_.text =
                                  [NSString stringWithFormat:@"%ld°", lround([weather.temp doubleValue])];
                                 descriptionView_.text = [weather.desc uppercaseString];
                               });
                              }
                             failure:^(NSError *error) {
                               [debugger_ debug:@"Failed to retrieve weather data"];
                              }];
  [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  
}

#pragma mark -
#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
  [locationManager_ startUpdatingLocation]; 
}

@end
