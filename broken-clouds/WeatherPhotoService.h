//
//  WeatherPhotoService.h
//  broken-clouds
//
//  Created by Min Kim on 5/18/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"

typedef void (^PhotoServiceResultBlock)(NSArray *photos);
typedef void (^PhotoServiceErrorBlock)(NSError *error);
typedef void (^PhotoUploadResultBlock)(NSArray *forecasts);

@interface WeatherPhotoService : NSObject {
@private
  NSMutableDictionary *photoMapByWeather_;
  CLLocationCoordinate2D lastPhotoUpdatedCoord_;
  NSTimeInterval lastPhotoUpdated_;
}

@property (nonatomic, retain) NSArray *lastPhotos;

- (void)getWeatherPhotoByCoord:(double)latitude
                     longitude:(double)longitude
                     weatherId:(IFWeatherId)weatherId
                     timestamp:(long)timestamp
                           day:(BOOL)day
                       success:(PhotoServiceResultBlock)success
                       failure:(PhotoServiceErrorBlock)failure;

- (void)postWeatherPhotoByCoord:(double)latitude
                      longitude:(double)longitude
                      weatherId:(IFWeatherId)weatherId
                          photo:(UIImage *)photo
                      timestamp:(long)timestamp
                            day:(BOOL)day
                        success:(PhotoUploadResultBlock)success
                        failure:(PhotoServiceErrorBlock)failure;
@end
