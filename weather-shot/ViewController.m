//
//  ViewController.m
//  weather-shot
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "ViewController.h"

#import "BasicTypes.h"
#import "UIDebugger.h"
#import "Weather.h"
#import "WeatherService.h"

int kMockupNum = 15;
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
}

- (void)refreshScreen {
  STOP_NSTIMER(refreshTimer_)
  [imageView_ setImage:[self getCurrentMockup]];
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
  [debugger_ debug:[NSString stringWithFormat:@"Retrieved new location coord(%f, %f)",
                    newLocation.coordinate.latitude,
                    newLocation.coordinate.longitude]];
  
  [weatherService_ getWeatherByGoordinate:newLocation.coordinate.latitude
                                longitude:newLocation.coordinate.longitude
                                  success:^(Weather *weather) {
                                    [debugger_ debug:[NSString stringWithFormat:@"name: %@, temp: %@, desc: %@",
                                                      weather.name,
                                                      weather.temp,
                                                      weather.desc]];
                                    
                                    locationView_.text = [weather.name uppercaseString];
                                    tempView_.text =
                                      [NSString stringWithFormat:@"%.01f°", [weather.temp doubleValue]];
                                    descriptionView_.text = [weather.desc uppercaseString];
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
