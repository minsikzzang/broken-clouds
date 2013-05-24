//
//  WeatherPhotoService.m
//  broken-clouds
//
//  Created by Min Kim on 5/18/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherPhotoService.h"

#import "AFJSONRequestOperation.h"
#import "BasicTypes.h"

@implementation WeatherPhotoService

NSString const* PhotoServerUrl = @"http://ec2-176-34-76-198.eu-west-1.compute.amazonaws.com:8080/weather-photo-server";
const int kPhotoLimit = 10;

- (void)getWeatherPhotoByCoord:(double)latitude
                     longitude:(double)longitude
                     weatherId:(IFWeatherId)weatherId
                     timestamp:(long)timestamp
                           day:(BOOL)day
                       success:(void (^)(NSArray *forecasts))success
                       failure:(void (^)(NSError *error))failure {
  NSString *uri = [NSString stringWithFormat:@"%@/photo?lat=%f&lng=%f&weather=%d&limit=%d",
                   PhotoServerUrl, latitude, longitude, weatherId, kPhotoLimit];
  NSURL *url = [NSURL URLWithString:uri];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFJSONRequestOperation *operation =
  [AFJSONRequestOperation
   JSONRequestOperationWithRequest:request
   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
     success([[IFObject ifObjectWrappingObject:JSON] valueForKey:@"photos"]);
   }
   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
     failure(error);
   }];
  
  [operation start];

}

@end
