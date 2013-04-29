//
//  Weather.h
//  weather-shot
//
//  Created by Min Kim on 4/25/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFObject.h"

enum {
  ThunderStormWithLightRain = 200,
  ThunderStormWithRain,
  ThunderStormWithHeavyRain,
  LightThunderStorm = 210,
  ThunderStorm,
  HeavyThunderStorm,
  RaggedThunderStorm = 221,
  ThunderStormWithLightDrizzle = 230,
  ThunderStormWithDrizzle,
  ThunderStormWithHeavyDrizzle,
  LightIntensityDrizzle = 300,
  Drizzle,
  HeavyIntensityDrizzle,
  LightIntensityDrizzleRain = 310,
  DrizzleRain,
  HeavyIntensityDrizzleRain,
  ShowerDrizzle = 321,
  500	 light rain	 [[file:10d.png]]
  501	 moderate rain	 [[file:10d.png]]
  502	 heavy intensity rain	 [[file:10d.png]]
  503	 very heavy rain	 [[file:10d.png]]
  504	 extreme rain	 [[file:10d.png]]
  511	 freezing rain	 [[file:13d.png]]
  520	 light intensity shower rain	 [[file:09d.png]]
  521	 shower rain	 [[file:09d.png]]
  522	 heavy intensity shower rain	 [[file:09d.png]]
  Snow
  ID	 Meaning	Icon
  600	 light snow	 [[file:13d.png]]
  601	 snow	 [[file:13d.png]]
  602	 heavy snow	 [[file:13d.png]]
  611	 sleet	 [[file:13d.png]]
  621	 shower snow	 [[file:13d.png]]
  Atmosphere
  ID	 Meaning	Icon
  701	 mist	 [[file:50d.png]]
  711	 smoke	 [[file:50d.png]]
  721	 haze	 [[file:50d.png]]
  731	 Sand/Dust Whirls	 [[file:50d.png]]
  741	 Fog	 [[file:50d.png]]
  Clouds
  ID	 Meaning	Icon
  800	 sky is clear	 [[file:01d.png]] [[file:01n.png]]
  801	 few clouds	 [[file:02d.png]] [[file:02n.png]]
  802	 scattered clouds	 [[file:03d.png]] [[file:03d.png]]
  803	 broken clouds	 [[file:04d.png]] [[file:03d.png]]
  804	 overcast clouds	 [[file:04d.png]] [[file:04d.png]]
  Extreme
  ID	 Meaning
  900	 tornado
  901	 tropical storm
  902	 hurricane
  903	 cold
  904	 hot
  905	 windy
  906	 hail
};

@interface Weather : NSMutableDictionary<IFObject>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *temp;
@property (nonatomic, retain) NSString *weatherId;
@property (nonatomic, assign) double high;
@property (nonatomic, assign) double low;

@end
