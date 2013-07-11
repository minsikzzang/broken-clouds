//
//  WeatherService.h
//  weather-shot
//
//  Created by Min Kim on 4/9/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Weather;

@interface WeatherService : NSObject {
@private
  NSTimeInterval lastWeatherUpdated_;
  CLLocationCoordinate2D lastWeatherUpdatedCoord_;
  NSTimeInterval lastDailyForecastUpdated_;
  CLLocationCoordinate2D lastDailyForecastUpdatedCoord_;
  NSTimeInterval lastHourlyForecastUpdated_;
  CLLocationCoordinate2D lastHourlyForecastUpdatedCoord_;
}

@property (nonatomic, retain) Weather *lastWeather;
@property (nonatomic, retain) NSArray *lastHourlyForecasts;
@property (nonatomic, retain) NSArray *lastDailyForecasts;

- (NSTimeInterval)getLastUpdatedTimeFromNow;

- (void)getWeatherByCoord:(double)latitude
                longitude:(double)longitude
                  success:(void (^)(Weather *weather))success
                  failure:(void (^)(NSError *error))failure;

- (void)getForecastByCoord:(double)latitude
                 longitude:(double)longitude
                     daily:(BOOL)daily
                     count:(int)count
                   success:(void (^)(NSArray *forecasts))success
                   failure:(void (^)(NSError *error))failure;

@end
