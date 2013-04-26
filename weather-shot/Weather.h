//
//  Weather.h
//  weather-shot
//
//  Created by Min Kim on 4/25/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFObject.h"

@interface Weather : NSMutableDictionary<IFObject>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *temp;
@property (nonatomic, assign) double high;
@property (nonatomic, assign) double low;

@end
