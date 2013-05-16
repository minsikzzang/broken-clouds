//
//  WeatherIconFactory.m
//  weather-shot
//
//  Created by Min Kim on 4/29/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherIconFactory.h"

#import "EDSunriseSet.h"
#import "JSONKit.h"
#import "Weather.h"

@implementation WeatherIconFactory

@synthesize day;
@synthesize weatherId;

static NSString const* iconMapJson =
@"{\"300\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"301\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"302\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"310\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"311\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"312\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"321\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"500\":{\"day\":\"cloudy-with-light-rain.png\",\"night\":\"cloudy-with-light-rain.png\"},\
\"501\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"502\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"503\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"504\":{\"day\":\"heavy-rail-shower.png\",\"night\":\"heavy-rail-shower.png\"},\
\"511\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"520\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"521\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"522\":{\"day\":\"heavy-rain-shower.png\",\"night\":\"heavy-rain-shower.png\"},\
\"600\":{\"day\":\"light-snow-shower.png\",\"night\":\"light-snow-shower.png\"},\
\"601\":{\"day\":\"light-snow-shower.png\",\"night\":\"light-snow-shower.png\"},\
\"602\":{\"day\":\"light-snow-shower.png\",\"night\":\"light-snow-shower.png\"},\
\"611\":{\"day\":\"light-snow-shower.png\",\"night\":\"light-snow-shower.png\"},\
\"621\":{\"day\":\"light-snow-shower.png\",\"night\":\"light-snow-shower.png\"},\
\"701\":{\"day\":\"mist.png\",\"night\":\"mist.png\"},\
\"711\":{\"day\":\"mist.png\",\"night\":\"mist.png\"},\
\"721\":{\"day\":\"mist.png\",\"night\":\"mist.png\"},\
\"731\":{\"day\":\"mist.png\",\"night\":\"mist.png\"},\
\"741\":{\"day\":\"mist.png\",\"night\":\"mist.png\"},\
\"800\":{\"day\":\"sunny.png\",\"night\":\"clear-sky-night.png\"},\
\"801\":{\"day\":\"sunny-spells.png\",\"night\":\"clear-sky-night.png\"},\
\"802\":{\"day\":\"sunny-spells.png\",\"night\":\"clear-sky-night.png\"},\
\"803\":{\"day\":\"sunny-spells.png\",\"night\":\"overcast.png\"},\
\"804\":{\"day\":\"overcast.png\",\"night\":\"overcast.png\"}}";

+ (WeatherIconFactory *)buildFactory:(Weather *)weather
                                 lat:(double)lat
                                 lng:(double)lng
                                 now:(NSDate *)now {
  EDSunriseSet *sun = [EDSunriseSet sunrisesetWithTimezone:[NSTimeZone localTimeZone]
                                                  latitude:lat
                                                 longitude:lng];
  [sun calculate:now];
  return [[[WeatherIconFactory alloc]
           initWithWeather:weather
           day:([now compare:sun.sunrise] == 1 &&
                [now compare:sun.sunset] == -1)] autorelease];
}

+ (WeatherIconFactory *)buildFactory:(NSString *)weatherId
                                 day:(BOOL)day {
  return [[WeatherIconFactory alloc] initWithWeatherId:weatherId day:day];
}

- (id)initWithWeather:(Weather *)weather day:(BOOL)day_ {
  self = [super init];
  if (self) {
    [self initWithWeatherId:weather.weatherId day:day_];
  }
  return self;
}
          
- (id)initWithWeatherId:(NSString *)id day:(BOOL)day_ {
  self = [super init];
  if (self) {
    self.day = day_;
    self.weatherId = (IFWeatherId)[id intValue];
  }
  return self;
}


- (UIImage *)build {
  NSDictionary *o =
    [[iconMapJson objectFromJSONString]
     valueForKey:[NSString stringWithFormat:@"%d",
                  self.weatherId]];
  return [UIImage imageNamed:[o valueForKey:(self.day ? @"day" : @"night")]];
}

- (void)dealloc {
  [super dealloc];
}

@end
