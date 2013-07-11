//
//  IFTimeAndSpace.m
//  broken-clouds
//
//  Created by Min Kim on 5/30/13.
//  Copyright (c) 2013 iFactory Lab. All rights reserved.
//

#import "IFLocation.h"
#import "BasicTypes.h"

const int kMaxLocationUpdate = 100;

@implementation IFLocation

@synthesize now = now_;
@synthesize coord = coord_;
@synthesize errorBlock;
@synthesize resultBlock;

- (id)init {
  self = [super init];
  if (self) {
    locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.delegate = self;
    lastGeoUpdatedTime_ = 0;
  }
  return self;
}

- (void)dealloc {
  SAFE_RELEASE(locationManager_)
  [super dealloc];
}

- (NSTimeInterval)getNow {
  return [[NSDate date] timeIntervalSince1970];
}

- (void)startUpdate:(IFLocationResultsBlock)resultBlock_
         errorBlock:(IFLocationErrorBlock)errorBlock_ {
  self.resultBlock = resultBlock_;
  self.errorBlock = errorBlock_;
  
  if (self.now - lastGeoUpdatedTime_ > kMaxLocationUpdate) {
    [locationManager_ startUpdatingLocation];
  } else {
    resultBlock_(self);
  }
}

#pragma mark -
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  [manager stopUpdatingLocation];
  
  lastGeoUpdatedTime_ = [[NSDate date] timeIntervalSince1970];
  self.coord = newLocation.coordinate;
  self.resultBlock(self);
  
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  self.errorBlock(error);
}


@end
