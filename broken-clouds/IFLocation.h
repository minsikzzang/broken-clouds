//
//  IFLocation.h
//  broken-clouds
//
//  Created by Min Kim on 5/30/13.
//  Copyright (c) 2013 iFactory Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFLocation;

typedef void (^IFLocationResultsBlock)(IFLocation *location);
typedef void (^IFLocationErrorBlock)(NSError *error);

@interface IFLocation : NSObject<CLLocationManagerDelegate> {
@private
  NSTimeInterval now_;
  NSTimeInterval lastGeoUpdatedTime_;
  CLLocationCoordinate2D coord_;
  CLLocationManager *locationManager_;
}

- (void)startUpdate:(IFLocationResultsBlock)resultBlock
         errorBlock:(IFLocationErrorBlock)errorBlock;

@property (nonatomic, assign, getter=getNow) NSTimeInterval now;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, copy) IFLocationResultsBlock resultBlock;
@property (nonatomic, copy) IFLocationErrorBlock errorBlock;

@end
