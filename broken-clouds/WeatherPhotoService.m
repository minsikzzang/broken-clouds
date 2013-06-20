//
//  WeatherPhotoService.m
//  broken-clouds
//
//  Created by Min Kim on 5/18/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "WeatherPhotoService.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "BasicTypes.h"
#import "UIImage+Resizing.h"
#import "MapKit/MapKit.h"

@interface WeatherPhotoService()

- (BOOL)isPhotoUpdateRequired:(CLLocationCoordinate2D)coord;
- (void)cacheLastPhotos:(NSArray *)photos
              withCoord:(CLLocationCoordinate2D)coord;

@end

NSString const* PhotoServerUrl = @"http://api.ifactory-lab.com:8080";
// NSString const* PhotoServerUrl = @"http://192.168.0.2:8080/weather-photo-server";

const int kLimitDistancePhotoUpdate = 500; // 500 m -> 0.5 km
const int kLimitTimePhotoUpdate = 60; // 60 seconds -> 1 minutes
const int kPhotoLimit = 10;
const CGFloat kMaxPhotoHeight = 640.0;
const CGFloat kMaxPhotoWidth = 640.0;

@implementation WeatherPhotoService

@synthesize lastPhotos;

- (BOOL)isPhotoUpdateRequired:(CLLocationCoordinate2D)coord {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  double meters = DISTANCE_BETWEEN(coord, lastPhotoUpdatedCoord_)
  NSLog(@"%lf meters far from previous point", meters);
  NSLog(@"%lf seconds passed from previous photo update", (now - lastPhotoUpdated_));
  return ((meters >= kLimitDistancePhotoUpdate) ||
          (now - lastPhotoUpdated_) > kLimitTimePhotoUpdate);
}

- (void)cacheLastPhotos:(NSArray *)photos
              withCoord:(CLLocationCoordinate2D)coord {
  lastPhotoUpdated_ = [[NSDate date] timeIntervalSince1970];
  lastPhotoUpdatedCoord_ = coord;
  self.lastPhotos = photos;
}

- (void)getWeatherPhotoByCoord:(double)latitude
                     longitude:(double)longitude
                     weatherId:(IFWeatherId)weatherId
                     timestamp:(long)timestamp
                           day:(BOOL)day
                       success:(PhotoServiceResultBlock)success
                       failure:(PhotoServiceErrorBlock)failure {
  CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
  if ([self isPhotoUpdateRequired:coord]) {
    NSString *uri = [NSString stringWithFormat:@"%@/weather-photo-server/photo?lat=%f&lng=%f&weather=%d&limit=%d",
                     PhotoServerUrl, latitude, longitude, weatherId, kPhotoLimit];
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
       NSArray *photos = [[IFObject ifObjectWrappingObject:JSON] valueForKey:@"photos"];
       success(photos);
       [self cacheLastPhotos:photos withCoord:coord];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
       failure(error);
     }];
    
    [operation start];
  } else {
    success(self.lastPhotos);
  }
}

- (CGSize)resize:(CGSize)size uptoMax:(CGSize)max {
  // Need to keep ratio. Height has to be longer than width.
  if (size.height > max.height) {
    return CGSizeMake(max.height * size.width / size.height, max.height);
  } else if (size.width > max.width) {
    return CGSizeMake(max.width, size.height * max.width / size.width);
  }
  
  return size;
}

- (void)postWeatherPhotoByCoord:(double)latitude
                      longitude:(double)longitude
                      weatherId:(IFWeatherId)weatherId
                          photo:(UIImage *)photo
                      timestamp:(long)timestamp
                            day:(BOOL)day
                        success:(PhotoUploadResultBlock)success
                        failure:(PhotoServiceErrorBlock)failure {
  NSLog(@"%lf, %lf, %d, %ld", latitude, longitude, weatherId, timestamp);
  NSLog(@"%@", photo);
  
  NSURL *url = [NSURL URLWithString:(NSString *)PhotoServerUrl];
  AFHTTPClient *client = [[[AFHTTPClient alloc] initWithBaseURL:url] autorelease];
  NSDictionary *params = @{@"lat" : [NSString stringWithFormat:@"%lf", latitude],
                           @"lng" : [NSString stringWithFormat:@"%lf", longitude],
                           @"weather" : [NSString stringWithFormat:@"%d", weatherId],
                           @"timestamp" : [NSString stringWithFormat:@"%ld", timestamp],
                           };
  
  CGSize size = [self resize:photo.size
                     uptoMax:CGSizeMake(kMaxPhotoWidth, kMaxPhotoHeight)];
  // Resize the given image to less than max size.
  NSData *data = UIImagePNGRepresentation([photo scaleToSize:size]);
  NSMutableURLRequest *request =
    [client multipartFormRequestWithMethod:@"POST"
                                      path:@"/weather-photo-server/photo"
                                parameters:params
                 constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                   [formData appendPartWithFileData:data
                                               name:@"photo"
                                           fileName:@"photo.png"
                                           mimeType:@"image/png"];
                 }];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                      long long totalBytesWritten,
                                      long long totalBytesExpectedToWrite) {
    // NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
  }];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (operation.response.statusCode == 200 ||
        operation.response.statusCode == 201) {
      NSLog(@"Created, %@", [IFObject ifObjectWrappingObject:responseObject]);
      // NSDictionary *updatedLatte = [responseObject objectForKey:@"latte"];
      
    } else {
      
    }
    [operation release];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@", [error localizedDescription]);
    // completionBlock(NO, error);
    [operation release];
  }];
  
  [client enqueueHTTPRequestOperation:operation];
}

@end
