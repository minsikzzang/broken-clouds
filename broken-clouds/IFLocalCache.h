//
//  IFLocalCache.h
//  broken-clouds
//
//  Created by Min Kim on 6/4/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFLocalCache : NSObject {
@private
  NSInteger maxSize_;
  NSString *storagePath_;
  NSMutableDictionary *memoryStorage_;
}

@property (nonatomic, readwrite) NSInteger maxSize;
@property (nonatomic, retain) NSString *storagePath;

// + (id)sharedCache;

- (void)clearCache;

- (void)storeCache:(NSString *)key
         andMaxAge:(NSInteger)maxAge
           andData:(NSData *)data;

- (void)storeCacheForURL:(NSURL *)url
               andMaxAge:(NSInteger)maxAge
                 andData:(NSData *)data;

- (void)deleteCache:(NSString *)key;

- (void)deleteCacheForURL:(NSURL *)url;

- (void)cacheImageForURL:(NSURL *)url
               andMaxAge:(NSInteger)maxAge
                andImage:(UIImage *)image;

- (NSData *)cachedDataForURL:(NSURL *)url;

- (UIImage *)cachedImageForURL:(NSURL *)url;

- (NSData *)cachedData:(NSString *)key;

@end