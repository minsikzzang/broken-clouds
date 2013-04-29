//
//  WeatherIconFactory.h
//  weather-shot
//
//  Created by Min Kim on 4/29/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Weather;

@interface WeatherIconFactory : NSObject

- (id)initWithWeather:(Weather *)weather day:(BOOL)day;

+ (WeatherIconFactory *)buildFactory:(Weather *)weather
                                 lat:(double)lat
                                 lng:(double)lng
                                 now:(NSDate *)now;

@property (nonatomic, assign) int weatherId;
@property (nonatomic, assign) BOOL day;

@end
