//
//  WeatherService.m
//  weather-shot
//
//  Created by Min Kim on 4/9/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherService.h"

#import "AFJSONRequestOperation.h"
#import "Weather.h"

@implementation WeatherService

NSString const* kWeatherServerUrl = @"http://ec2-176-34-76-198.eu-west-1.compute.amazonaws.com:8080/weather-server";

- (void)getWeatherByCoord:(double)latitude
                longitude:(double)longitude
                  success:(void (^)(Weather *weather))success
                  failure:(void (^)(NSError *error))failure {
  NSString *uri = [NSString stringWithFormat:@"%@/weather?lat=%f&lng=%f",
                   kWeatherServerUrl, latitude, longitude];
  NSURL *url = [NSURL URLWithString:uri];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
       success([IFObject ifObjectWrappingObject:JSON]);
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
       failure(error);
     }];
  
  [operation start];
}

@end
