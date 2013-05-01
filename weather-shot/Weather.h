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
  LightRain = 500,
  ModerateRain,
  HeavyIntensityRain,
  VeryHeavyRain,
  ExtremeRain,
  FreezingRain = 511,
  LightIntensityShowerRain = 520,
  ShowerRain,
  HeavyIntensityShowerRain,
  LightSnow = 600,
  Snow,
  HeavySnow,
  Sleet = 611,
  ShowerSnow = 621,
  Mist = 701,
  Smoke = 711,
  Haze = 721,
  SandDustWhirls = 731,
  Fog = 741,
  SkyIsClear = 800,
  FewClouds,
  ScatteredClouds,
  BrokenClouds,
  OvercastClouds,
  Tornado = 900,
  TropicalStorm,
  Hurricane,
  Cold,
  Hot,
  Windy,
  Hail
};
typedef NSUInteger IFWeatherId;

@interface Weather : NSMutableDictionary<IFObject>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *temp;
@property (nonatomic, retain) NSString *weatherId;
@property (nonatomic, assign) double high;
@property (nonatomic, assign) double low;

@end
