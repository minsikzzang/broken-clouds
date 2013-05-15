//
//  Forecast.h
//  broken-clouds
//
//  Created by Min Kim on 5/15/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFObject.h"

@interface Forecast : NSMutableDictionary<IFObject>

@property (nonatomic, retain) NSString *dt;
@property (nonatomic, retain) NSString *high;
@property (nonatomic, retain) NSString *low;
@property (nonatomic, retain) NSString *temp;
@property (nonatomic, retain) id weather;

@end
