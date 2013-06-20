//
//  WeatherService.m
//  weather-shot
//
//  Created by Min Kim on 4/9/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherService.h"

#import "AFJSONRequestOperation.h"
#import "BasicTypes.h"
#import "Weather.h"
#import "MapKit/MapKit.h"

@interface WeatherService()

- (BOOL)isWeatherUpdateRequired:(CLLocationCoordinate2D)coord;
- (BOOL)isDailyForecastUpdateRequired:(CLLocationCoordinate2D)coord;
- (BOOL)isHourlyForecastUpdateRequired:(CLLocationCoordinate2D)coord;
- (void)cacheLastWeather:(Weather *)weather
               withCoord:(CLLocationCoordinate2D)coord;
- (void)cacheLastHourlyForecast:(NSArray *)forecasts
                      withCoord:(CLLocationCoordinate2D)coord;
- (void)cacheLastDailyForecast:(NSArray *)forecasts
                     withCoord:(CLLocationCoordinate2D)coord;

@end

NSString const* kWeatherServerUrl = @"http://api.ifactory-lab.com:8080/weather-server";
const int kLimitDistanceWeatherUpdate = 1000; // 1000 m -> 1 km
const int kLimitTimeWeatherUpdate = 300; // 300 seconds -> 5 minutes
const int kLimitDistanceForecastUpdate = 1000; // 1000 m -> 1 km
const int kLimitTimeForecastUpdate = 60 * 60; // 3600 seconds -> 1 hour

@implementation WeatherService

@synthesize lastDailyForecasts;
@synthesize lastHourlyForecasts;
@synthesize lastWeather;

- (BOOL)isWeatherUpdateRequired:(CLLocationCoordinate2D)coord {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  double meters = DISTANCE_BETWEEN(coord, lastWeatherUpdatedCoord_)
  NSLog(@"%lf meters far from previous point", meters);
  NSLog(@"%lf seconds passed from previous update", (now - lastWeatherUpdated_));
  return ((meters >= kLimitDistanceWeatherUpdate) ||
          (now - lastWeatherUpdated_) > kLimitTimeWeatherUpdate);
}

- (BOOL)isDailyForecastUpdateRequired:(CLLocationCoordinate2D)coord {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  double meters = DISTANCE_BETWEEN(coord, lastDailyForecastUpdatedCoord_)
  NSLog(@"%lf meters far from previous point", meters);
  NSLog(@"%lf seconds passed from previous daily update", (now - lastDailyForecastUpdated_));
  return ((meters >= kLimitDistanceForecastUpdate) ||
          (now - lastDailyForecastUpdated_) > kLimitTimeForecastUpdate);
}

- (BOOL)isHourlyForecastUpdateRequired:(CLLocationCoordinate2D)coord {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  double meters = DISTANCE_BETWEEN(coord, lastHourlyForecastUpdatedCoord_)
  NSLog(@"%lf meters far from previous point", meters);
  NSLog(@"%lf seconds passed from previous hourly update", (now - lastHourlyForecastUpdated_));
  return ((meters >= kLimitDistanceForecastUpdate) ||
          (now - lastHourlyForecastUpdated_) > kLimitTimeForecastUpdate);
}

- (void)cacheLastWeather:(Weather *)weather
               withCoord:(CLLocationCoordinate2D)coord {
  lastWeatherUpdated_ = [[NSDate date] timeIntervalSince1970];
  lastWeatherUpdatedCoord_ = coord;
  self.lastWeather = weather;
}

- (void)cacheLastHourlyForecast:(NSArray *)forecasts
                      withCoord:(CLLocationCoordinate2D)coord {
  lastHourlyForecastUpdated_ = [[NSDate date] timeIntervalSince1970];
  lastHourlyForecastUpdatedCoord_ = coord;
  self.lastHourlyForecasts = forecasts;
}

- (void)cacheLastDailyForecast:(NSArray *)forecasts
                     withCoord:(CLLocationCoordinate2D)coord {
  lastDailyForecastUpdated_ = [[NSDate date] timeIntervalSince1970];
  lastDailyForecastUpdatedCoord_ = coord;
  self.lastDailyForecasts = forecasts;
}

- (void)getWeatherByCoord:(double)latitude
                longitude:(double)longitude
                  success:(void (^)(Weather *weather))success
                  failure:(void (^)(NSError *error))failure {
  CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);  
  if ([self isWeatherUpdateRequired:coord]) {
    NSString *uri = [NSString stringWithFormat:@"%@/weather?lat=%f&lng=%f",
                     kWeatherServerUrl, latitude, longitude];
    
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
       Weather *weather = [IFObject ifObjectWrappingObject:JSON];
       success(weather);
       [self cacheLastWeather:weather withCoord:coord];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
       failure(error);
     }];
    
    [operation start];
  } else {
    // If update is not required, use last updated weather data
    success(self.lastWeather);
  }
}

- (void)getForecastByCoord:(double)latitude
                 longitude:(double)longitude
                     daily:(BOOL)daily
                     count:(int)count
                   success:(void (^)(NSArray *forecasts))success
                   failure:(void (^)(NSError *error))failure {
  CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
  BOOL updateRequired = (daily ? [self isDailyForecastUpdateRequired:coord] :
                         [self isHourlyForecastUpdateRequired:coord]);
  
  if (updateRequired) {
    NSString *uri = [NSString stringWithFormat:@"%@/forecast?lat=%f&lng=%f&daily=%@&cnt=%d",
                     kWeatherServerUrl, latitude, longitude,
                     (daily ? @"true" : @"false"), count];
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
       NSDictionary *resp = [IFObject ifObjectWrappingObject:JSON];
       NSArray *forecasts = [resp objectForKey:@"forecasts"];
       success(forecasts);
       (daily ? [self cacheLastDailyForecast:forecasts withCoord:coord] :
        [self cacheLastHourlyForecast:forecasts withCoord:coord]);
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
       failure(error);
     }];
    
    [operation start];
  } else {
    success(daily ? self.lastDailyForecasts : self.lastHourlyForecasts);
  }
}
@end
