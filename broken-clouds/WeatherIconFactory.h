//
//  WeatherIconFactory.h
//  weather-shot
//
//  Created by Min Kim on 4/29/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"

@interface WeatherIconFactory : NSObject {
@private
}

@property (nonatomic, assign) IFWeatherId weatherId;
@property (nonatomic, assign) BOOL day;

+ (WeatherIconFactory *)buildFactory:(Weather *)weather
                                 lat:(double)lat
                                 lng:(double)lng
                                 now:(NSDate *)now;

+ (WeatherIconFactory *)buildFactory:(NSString *)weatherId
                                 day:(BOOL)day;

- (id)initWithWeather:(Weather *)weather day:(BOOL)day;

- (id)initWithWeatherId:(NSString *)id day:(BOOL)day_;

- (UIImage *)build;

@end
