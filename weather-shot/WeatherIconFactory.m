//
//  WeatherIconFactory.m
//  weather-shot
//
//  Created by Min Kim on 4/29/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherIconFactory.h"

#import "EDSunriseSet.h"
#import "Weather.h"

@implementation WeatherIconFactory

@synthesize day;
@synthesize weatherId;

+ (WeatherIconFactory *)buildFactory:(Weather *)weather
                                 lat:(double)lat
                                 lng:(double)lng
                                 now:(NSDate *)now {
  EDSunriseSet *sun = [EDSunriseSet sunrisesetWithTimezone:[NSTimeZone localTimeZone]
                                                  latitude:lat
                                                 longitude:lng];
  [sun calculate:now];
  BOOL day = ([now compare:sun.sunrise] == 1 && [now compare:sun.sunset] == -1);  
  return [[[WeatherIconFactory alloc] initWithWeather:weather day:day] autorelease];
}

- (id)initWithWeather:(Weather *)weather day:(BOOL)day_ {
  self = [super init];
  if (self) {
    self.day = day_;
    self.weatherId = weatherId;
  }
  return self;
}

@end
