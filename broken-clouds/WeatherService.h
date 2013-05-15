//
//  WeatherService.h
//  weather-shot
//
//  Created by Min Kim on 4/9/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Weather;

@interface WeatherService : NSObject

- (void)getWeatherByCoord:(double)latitude
                longitude:(double)longitude
                  success:(void (^)(Weather *weather))success
                  failure:(void (^)(NSError *error))failure;

- (void)getForecastByCoord:(double)latitude
                 longitude:(double)longitude
                     daily:(BOOL)daily
                   success:(void (^)(NSArray *forecasts, BOOL daily))success
                   failure:(void (^)(NSError *error))failure;

@end
