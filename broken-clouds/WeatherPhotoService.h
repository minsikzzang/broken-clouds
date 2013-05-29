//
//  WeatherPhotoService.h
//  broken-clouds
//
//  Created by Min Kim on 5/18/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"

@interface WeatherPhotoService : NSObject {
@private
  NSMutableDictionary *photoMapByWeather_;
}

- (void)getWeatherPhotoByCoord:(double)latitude
                     longitude:(double)longitude
                     weatherId:(IFWeatherId)weatherId
                     timestamp:(long)timestamp
                           day:(BOOL)day
                       success:(void (^)(NSArray *forecasts))success
                       failure:(void (^)(NSError *error))failure;

// - (void)postWeatherPhotoByCoord:(
@end
