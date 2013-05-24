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
#import "WeatherPhotoService.h"

static NSString *const kMockupName = @"mockup%d.png";
const int kMockupNum = 19;
const int kMockupRefresh = 5;
const int kSecond = 1;
const int kMaxHourlyForecast = 12;
const int kDailyForecastItemHeight = 40;
const int kMaxDailyForecast = 6;
const int kMarginUnderScreen = 50;
const int kPoweredByHeight = 20;

@interface ViewController ()

- (UIImage *)getCurrentMockup;
- (void)refreshScreen;
- (void)updateDate;
- (void)handleWeather:(Weather *)weather
            withCoord:(CLLocationCoordinate2D)coord;
- (void)handleDailyForecast:(NSArray *)forecasts;
- (void)handleHourlyForecast:(NSArray *)forecasts;

@end

@implementation ViewController

- (UIImage *)getCurrentMockup {
  @synchronized (self) {
    if (mockups_.count <= currentMockup_) {
      currentMockup_ = 0;
    }
    return [mockups_ objectAtIndex:currentMockup_++];
  } 
  return nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
	// Initialize location manager to get current location data
  weatherService_ = [[WeatherService alloc] init];
  photoService_ = [[WeatherPhotoService alloc] init];
  
  debugger_ = [[UIDebugger alloc] init];
  debugger_.parent = debugView_;
  [debugger_ attach];
  
  locationManager_ = [[CLLocationManager alloc] init];
  locationManager_.delegate = self;
  [locationManager_ startUpdatingLocation];
    
  // Load all mockup images and start timer to display in roundrobin way.
  mockups_ = [[NSMutableArray alloc] init];
  
  /*
  for (int i = 0; i < kMockupNum; ++i) {
    NSString *mockup = [NSString stringWithFormat:kMockupName, i + 1];
    [mockups_ addObject:[UIImage imageNamed:mockup]];
  }
*/
  
  // Display first image and start timer
  currentMockup_ = 0;
  // [imageView_ setImage:[self getCurrentMockup]];

  hiddenLayerView_.delegate = self;
  
  // Initialize all the visual elements and views for hourly forecast view.
  hours_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
  hourlyTemps_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
  hourlyWeathers_ = [[NSMutableArray alloc] initWithCapacity:kMaxHourlyForecast];
    
  for (int i = 0; i < kMaxHourlyForecast; ++i) {
    int x = (i > 5 ? 7: 0);
    
    // Create a label for date. ex) 00, 02
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"GillSans-Bold" size:13];
    label.text = [NSString stringWithFormat:@"%02d", i * 3];
    label.frame = CGRectMake(330.0 + (i * 52) + x, 7.0, 40.0, 20.0);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0, -1);
    [hourlyWeatherView_ addSubview:label];
    [hours_ addObject:label];
    [label release];
    
    // Create a label for degree
    UILabel *temp = [[UILabel alloc] init];
    temp.textColor = [UIColor whiteColor];
    temp.textAlignment = NSTextAlignmentCenter;
    temp.font = [UIFont fontWithName:@"GillSans-Bold" size:17];
    temp.text = [NSString stringWithFormat:@"%02d°", i * 3];
    temp.frame = CGRectMake(330.0 + (i * 52) + x, 57.0, 40.0, 20.0);
    temp.backgroundColor = [UIColor clearColor];
    temp.shadowColor = [UIColor lightGrayColor];
    temp.shadowOffset = CGSizeMake(0, -1);
    [hourlyWeatherView_ addSubview:temp];
    [hourlyTemps_ addObject:temp];
    [temp release];
    
    // Create an image view for weather icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(330.0 + (i * 52) + (x - 1), 20.0, 40.0, 40.0);
    icon.backgroundColor = [UIColor clearColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [hourlyWeatherView_ addSubview:icon];
    [hourlyWeathers_ addObject:icon];
    [icon release];
  }
  
  // Initialize all the visual elements and views for daily forecast view.
  days_ = [[NSMutableArray alloc] initWithCapacity:kMaxDailyForecast];
  dailyMaxTemps_ = [[NSMutableArray alloc] initWithCapacity:kMaxDailyForecast];
  dailyMinTemps_ = [[NSMutableArray alloc] initWithCapacity:kMaxDailyForecast];
  dailyWeathers_ = [[NSMutableArray alloc] initWithCapacity:kMaxDailyForecast];
  
  for (int i = 0; i < kMaxDailyForecast; ++i) {
    // Create cell view for daily forecast.
    BOOL even = ((i + 1) % 2);
    BOOL last = (kMaxDailyForecast == i + 1);
    
    UIView *view = [[UIView alloc]
                    initWithFrame:CGRectMake(0.0,
                                             FRH(self.view.frame) +
                                             kMarginUnderScreen +
                                             (kDailyForecastItemHeight * i),
                                             FRW(self.view.frame),
                                             kDailyForecastItemHeight +
                                             (last ? kPoweredByHeight : 0))];

    view.backgroundColor =
      (even ? [[UIColor lightGrayColor] colorWithAlphaComponent:0.3] :
       [[UIColor darkGrayColor] colorWithAlphaComponent:0.3]);
    
    // If the view is last one, add powered by openweathermap.org text
    if (last) {
      UILabel *poweredBy = [[UILabel alloc] init];
      poweredBy.textColor = [UIColor whiteColor];
      poweredBy.textAlignment = NSTextAlignmentRight;
      poweredBy.font = [UIFont fontWithName:@"GillSans" size:10];
      poweredBy.text = @"Powered By Openweathermap.org";
      poweredBy.frame = CGRectMake(150.0, kDailyForecastItemHeight, 165.0, kPoweredByHeight);
      poweredBy.backgroundColor = [UIColor clearColor];
      [view addSubview:poweredBy];
      [poweredBy release];
    }
    
    // Create a label for day
    UILabel *day = [[UILabel alloc] init];
    day.textColor = [UIColor whiteColor];
    day.textAlignment = NSTextAlignmentLeft;
    day.font = [UIFont fontWithName:@"GillSans" size:18];
    day.text = @"Wednesday";
    day.frame = CGRectMake(12.0, 11.0, 90.0, kDailyForecastItemHeight - 11.0 * 2);
    day.backgroundColor = [UIColor clearColor];
    // day.shadowColor = [UIColor darkGrayColor];
    // day.shadowOffset = CGSizeMake(0, -1);
    [view addSubview:day];
    [days_ addObject:day];
    [day release];
    
    // Create an image view for weather icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(195.0, 0.0, 40.0, kDailyForecastItemHeight);
    icon.backgroundColor = [UIColor clearColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:icon];
    [dailyWeathers_ addObject:icon];
    icon.image = [UIImage imageNamed:(even ? @"overcast.png" : @"sunny-spells.png")];
    [icon release];

    // Create a label for maximum and minimum tempertures
    UILabel *maxTemp = [[UILabel alloc] init];
    maxTemp.textColor = [UIColor whiteColor];
    maxTemp.textAlignment = NSTextAlignmentLeft;
    maxTemp.font = [UIFont fontWithName:@"GillSans" size:19.0];
    maxTemp.text = [NSString stringWithFormat:@"%02d° / ", 5 + i * 3];
    maxTemp.frame = CGRectMake(250.0, 11.0, 45.0, kDailyForecastItemHeight - 11.0 * 2);
    maxTemp.backgroundColor = [UIColor clearColor];
    // maxTemp.shadowColor = [UIColor lightGrayColor];
    // maxTemp.shadowOffset = CGSizeMake(0, -1);
    [view addSubview:maxTemp];
    [dailyMaxTemps_ addObject:maxTemp];
    [maxTemp release];
    
    UILabel *minTemp = [[UILabel alloc] init];
    minTemp.textColor = [UIColor lightGrayColor];
    minTemp.textAlignment = NSTextAlignmentLeft;
    minTemp.font = [UIFont fontWithName:@"GillSans" size:14.0];
    minTemp.text = [NSString stringWithFormat:@"%02d°", 5 + i * 3];
    minTemp.frame = CGRectMake(295.0, 12.0, 25.0, kDailyForecastItemHeight - 12.0 * 2);
    minTemp.backgroundColor = [UIColor clearColor];
    // minTemp.shadowColor = [UIColor darkGrayColor];
    // minTemp.shadowOffset = CGSizeMake(0, -1);
    [view addSubview:minTemp];
    [dailyMinTemps_ addObject:minTemp];
    [minTemp release];
    
    [hiddenLayerView_ addSubview:view];
    [view release];    
  }
  
  // Initialize and start date timer
  START_NSTIMER_(dateTimer_, kSecond, updateDate, YES)
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  // Hourly weather view has 3 pages. In the first page, current temperature
  // is shown, and in the second and third, hourly forecasts will be shown.
  hourlyWeatherView_.contentSize =
    CGSizeMake(hourlyWeatherView_.frame.size.width * 3,
               hourlyWeatherView_.frame.size.height);
  
  // We need to extend screen height as much as height of daily forecast table
  // because the table should be displayed in hidden space bottom of main screen.
  hiddenLayerView_.contentSize =
    CGSizeMake(hiddenLayerView_.frame.size.width,
               hiddenLayerView_.frame.size.height +
               (kDailyForecastItemHeight * kMaxDailyForecast) +
               kMarginUnderScreen + kPoweredByHeight);
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
  SAFE_RELEASE(days_)
  SAFE_RELEASE(dailyMaxTemps_)
  SAFE_RELEASE(dailyMinTemps_)
  SAFE_RELEASE(dailyWeathers_)
  SAFE_RELEASE(debugView_)
  SAFE_RELEASE(locationManager_)
  SAFE_RELEASE(tempView_)
  SAFE_RELEASE(locationView_)
  SAFE_RELEASE(mockups_)
  SAFE_RELEASE(weatherService_)
  SAFE_RELEASE(photoService_)
  [super dealloc];
}

- (NSString *)tp:(NSString *)t {
  return [t
   stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
}

- (void)handleWeather:(Weather *)weather
            withCoord:(CLLocationCoordinate2D)coord {
  [debugger_ debug:[NSString stringWithFormat:
                    @"name:%@, temp:%@, desc:%@, id:%@",
                    weather.name,
                    weather.temp,
                    weather.desc,
                    weather.weatherId]];
  
  long now = [[NSNumber numberWithDouble:[[NSDate date]
                                         timeIntervalSince1970]]
             longValue];
  [photoService_ getWeatherPhotoByCoord:coord.latitude
                              longitude:coord.longitude
                              weatherId:[weather.weatherId intValue]
                              timestamp:now
                                    day:YES
                                success:^(NSArray *photos) {
                                  STOP_NSTIMER(refreshTimer_)
                                  
                                  for (id photo in photos) {
                                    [mockups_ addObject:[UIImage imageNamed:[self tp:[photo valueForKey:@"url"]]]];
                                    // NSLog(@"%@", [self tp:[photo valueForKey:@"url"]]);
                                  }
                                  
                                  // Initialize and start mockup refrsh timer
                                  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
                                }
                                failure:^(NSError *error) {

                                }];
                                  

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

- (void)handleDailyForecast:(NSArray *)forecasts {
  for (int i = 0; i < kMaxDailyForecast; ++i) {
    Forecast *f = [forecasts objectAtIndex:i];
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"EEEE"];
    format.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]
                     autorelease];
    NSString *dt = [NSString stringWithFormat:@"%@",
                    [format stringFromDate:
                     [NSDate dateWithTimeIntervalSince1970:[f.dt doubleValue]]]];
    
    WeatherIconFactory *factory =
      [WeatherIconFactory buildFactory:[f.weather objectForKey:@"id"]
                                   day:YES];
    
    ((UILabel *)[days_ objectAtIndex:i]).text = dt;
    ((UILabel *)[dailyMinTemps_ objectAtIndex:i]).text =
      [NSString stringWithFormat:@"%02ld°", lround([f.low doubleValue])];
    ((UILabel *)[dailyMaxTemps_ objectAtIndex:i]).text =
      [NSString stringWithFormat:@"%02ld° / ", lround([f.high doubleValue])];
    ((UIImageView *)[dailyWeathers_ objectAtIndex:i]).image = [factory build];
  }
}

- (void)handleHourlyForecast:(NSArray *)forecasts {
  for (int i = 0; i < kMaxHourlyForecast; ++i) {
    Forecast *f = [forecasts objectAtIndex:i];
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"HH"];
    format.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]
                     autorelease];
    NSString *dt = [NSString stringWithFormat:@"%@",
                    [format stringFromDate:
                     [NSDate dateWithTimeIntervalSince1970:[f.dt doubleValue]]]];
    int hour = [dt intValue];
    
    WeatherIconFactory *factory =
      [WeatherIconFactory buildFactory:[f.weather objectForKey:@"id"]
                                   day:(7 < hour && hour < 19)];
    
    ((UILabel *)[hours_ objectAtIndex:i]).text = dt;
    ((UILabel *)[hourlyTemps_ objectAtIndex:i]).text =
      [NSString stringWithFormat:@"%02ld°", lround([f.temp doubleValue])];
    ((UIImageView *)[hourlyWeathers_ objectAtIndex:i]).image = [factory build];
  }
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
                               [self handleWeather:weather withCoord:coord];
                              }
                             failure:^(NSError *error) {
                               [debugger_ debug:@"Failed to retrieve weather data"];
                              }];
  
  [weatherService_ getForecastByCoord:coord.latitude
                            longitude:coord.longitude
                                daily:NO
                                count:kMaxHourlyForecast
                              success:^(NSArray *forecasts) {
                                [self handleHourlyForecast:forecasts];
                              }
                              failure:^(NSError *error) {
                                
                              }];
  
  [weatherService_ getForecastByCoord:coord.latitude
                            longitude:coord.longitude
                                daily:YES
                                count:kMaxDailyForecast
                              success:^(NSArray *forecasts) {
                                [self handleDailyForecast:forecasts];
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
