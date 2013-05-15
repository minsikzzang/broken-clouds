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
#import "Forecast.h"
#import "HiddenScrollView.h"
#import "OutlinedLabel.h"
#import "UIDebugger.h"
#import "Weather.h"
#import "WeatherIconFactory.h"
#import "WeatherService.h"

static NSString *const kMockupName = @"mockup%d.png";
const int kMockupNum = 19;
const int kMockupRefresh = 5;
const int kSecond = 1;
const int kMaxHourlyForecast = 12;

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
  
  hours_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
  hourlyTemps_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
  hourlyWeathers_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
  
  for (int i = 0; i < kMaxHourlyForecast; ++i) {
    int x = (i > 5 ? 7: 0);
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"GillSans-Bold" size:13];
    label.text = [NSString stringWithFormat:@"%02d", i * 3];
    label.frame = CGRectMake(330.0 + (i * 52) + x, 5.0, 40.0, 20.0);
    label.backgroundColor = [UIColor clearColor];
    [hourlyWeatherView_ addSubview:label];
    [hours_ addObject:label];
    [label release];
    
    UILabel *temp = [[UILabel alloc] init];
    temp.textColor = [UIColor whiteColor];
    temp.textAlignment = NSTextAlignmentCenter;
    temp.font = [UIFont fontWithName:@"GillSans-Bold" size:17];
    temp.text = [NSString stringWithFormat:@"%02d°", i * 3];
    temp.frame = CGRectMake(330.0 + (i * 52) + x, 60.0, 40.0, 20.0);
    temp.backgroundColor = [UIColor clearColor];    
    [hourlyWeatherView_ addSubview:temp];
    [hourlyTemps_ addObject:temp];
    [temp release];
    
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(330.0 + (i * 52) + x, 20.0, 40.0, 40.0);
    icon.backgroundColor = [UIColor clearColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [hourlyWeatherView_ addSubview:icon];
    [hourlyWeathers_ addObject:icon];
    [icon release];
  }
  
  // Initialize and start mockup refrsh timer
  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
  
  // Initialize and start date timer
  START_NSTIMER_(dateTimer_, kSecond, updateDate, YES)
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  hourlyWeatherView_.contentSize = CGSizeMake(hourlyWeatherView_.frame.size.width * 3,
                                              hourlyWeatherView_.frame.size.height);
  hiddenLayerView_.contentSize = CGSizeMake(hiddenLayerView_.frame.size.width,
                                            hiddenLayerView_.frame.size.height + 300.0);
  // hourlyWeatherView_.delegate = self;
  // hourlyWeatherView_.scrollEnabled = YES;
  // hourlyWeatherView_.pagingEnabled = YES;
  
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
  SAFE_RELEASE(hours_)
  SAFE_RELEASE(hourlyTemps_)
  SAFE_RELEASE(hourlyWeathers_)
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
  
  [weatherService_ getForecastByCoord:coord.latitude
                            longitude:coord.longitude
                                daily:NO
                              success:^(NSArray *forecasts, BOOL daily) {
                                for (int i = 0; i < kMaxHourlyForecast; ++i) {
                                  Forecast *f = [forecasts objectAtIndex:i];
                                  NSDateFormatter *timeFormat = [[[NSDateFormatter alloc] init] autorelease];
                                  [timeFormat setDateFormat:@"HH"];
                                  timeFormat.locale =
                                    [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
                                  NSString *dt = [NSString stringWithFormat:@"%@",
                                   [timeFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[f.dt doubleValue]]]];
                                  
                                  WeatherIconFactory *factory =
                                    [WeatherIconFactory buildFactory:[f.weather objectForKey:@"id"]
                                                                 day:YES];

                                  NSLog(@"temp: %@, timestamp: %@, weather: %@", f.temp, dt, [f.weather objectForKey:@"id"]);
                                  // NSLog(@"high:%@, low:%@", f.high, f.low);
                                  ((UILabel *)[hours_ objectAtIndex:i]).text = dt;
                                  ((UILabel *)[hourlyTemps_ objectAtIndex:i]).text = [NSString stringWithFormat:@"%ld°", lround([f.temp doubleValue])];
                                  ((UIImageView *)[hourlyWeathers_ objectAtIndex:i]).image = [factory build];
                                }
                              }
                              failure:^(NSError *error) {
                                
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
