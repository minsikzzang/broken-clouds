//
//  IFCacheItem.h
//  broken-clouds
//
//  Created by Min Kim on 6/4/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFCacheItem : NSObject {
@private
  NSString *key_;
  long expire_;
  NSString *filePath_;
}

- (id)initWithKey:(NSString *)key
        andMaxAge:(NSInteger)maxAge
      andFilePath:(NSString *)filePath;

- (id)initWithFilepath:(NSString *)path;

- (BOOL)writeToFile:(NSString *)path;

@property (nonatomic, retain) NSString *key;
@property (nonatomic, readonly) long expire;
@property (nonatomic, retain) NSString *filePath;

@end