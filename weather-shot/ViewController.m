//
//  ViewController.m
//  weather-shot
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "ViewController.h"

#import "BasicTypes.h"
#import "Weather.h"
#import "WeatherService.h"

int kMockupNum = 8;
static NSString *const kMockupName = @"mockup%d.png";
int kMockupRefresh = 5;


@interface ViewController ()

- (UIImage *)getCurrentMockup;
- (void)refreshScreen;

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
  mockupView_ = [[UIImageView alloc] initWithImage:[self getCurrentMockup]];
  tempView_ = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 100.0, 40.0)];
  tempView_.backgroundColor = [UIColor clearColor];
  tempView_.textColor = [UIColor whiteColor];
  tempView_.font = [UIFont boldSystemFontOfSize:38.0];
  [mockupView_ addSubview:tempView_];
  
  locationView_ = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 10.0, 150.0, 20.0)];
  locationView_.backgroundColor = [UIColor clearColor];
  locationView_.textColor = [UIColor whiteColor];
  locationView_.font = [UIFont boldSystemFontOfSize:20.0];

  [mockupView_ addSubview:locationView_];
  
  [self.view addSubview:mockupView_];
  [mockupView_ release];
  
  // Initialize and start mockup refrsh timer
  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
}

- (void)refreshScreen {
  STOP_NSTIMER(refreshTimer_)
  [mockupView_ setImage:[self getCurrentMockup]];
  START_NSTIMER(refreshTimer_, kMockupRefresh, refreshScreen)
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  STOP_NSTIMER(refreshTimer_)
}

- (void)dealloc {
  STOP_NSTIMER(refreshTimer_)
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
  NSLog(@"%@", newLocation.description);
  NSLog(@"%@", oldLocation.description);
  NSLog(@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
  
  [weatherService_ getWeatherByGoordinate:newLocation.coordinate.latitude
                                longitude:newLocation.coordinate.longitude
                                  success:^(Weather *weather) {
                                    NSLog(@"name: %@, temp: %@", weather.name,
                                          weather.temp);
                                    locationView_.text = weather.name;
                                    tempView_.text =
                                      [NSString stringWithFormat:@"%.02f", [weather.temp doubleValue]];                                    
                                  }
                                  failure:^(NSError *error) {
                                    
                                  }];
  [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  
}

@end
