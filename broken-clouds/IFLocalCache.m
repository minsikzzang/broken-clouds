//
//  IFLocalCache.m
//  broken-clouds
//
//  Created by Min Kim on 6/4/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "IFLocalCache.h"

#import "BasicTypes.h"
#import <CommonCrypto/CommonHMAC.h>
#import "GTMObjectSingleton.h"
#import "IFCacheItem.h"

static NSInteger kIFLocalDefaultCacheSize = 8096;

static NSString *kReferenceCacheFolder = @"ReferenceStore";
static NSString *kFileCacheFolder = @"FileStore";
static NSString *kIFLocalCacheFolder = @"com.ifactory-lab.IFLocalCache";

@interface IFLocalCache ()
+ (NSString *)keyForURL:(NSURL *)url;
- (NSString *)pathToFile:(NSString *)file;
- (NSString *)pathToReference:(NSString *)reference;
- (BOOL)isCacheReachedMax;
- (void)addItem:(IFCacheItem *)ci;
- (IFCacheItem *)find:(NSString *)key;
- (void)removeItem:(NSString *)key;
- (void)setStoragePath:(NSString *)path;
@end

@implementation IFLocalCache

@synthesize storagePath = storagePath_;
@synthesize maxSize = maxSize_;

- (id)init {
  self = [super init];
  if (self) {
    maxSize_ = kIFLocalDefaultCacheSize;
    memoryStorage_ = [[NSMutableDictionary alloc] init];
    [self setStoragePath:
     [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                           NSUserDomainMask,
                                           YES) objectAtIndex:0]
      stringByAppendingPathComponent:kIFLocalCacheFolder]];
  }
  return self;
}

- (void)dealloc {
  SAFE_RELEASE(storagePath_)
  SAFE_RELEASE(memoryStorage_)
  [super dealloc];
}

+ (NSString *)keyForURL:(NSURL *)url {
	NSString *urlString = [url absoluteString];
	if ([urlString length] == 0) {
		return nil;
	}
  
	// Strip trailing slashes so http://livestation.com/foo/ is cached the same as
  // http://livestation.com/foo
	if ([[urlString substringFromIndex:[urlString length] - 1]
       isEqualToString:@"/"]) {
		urlString = [urlString substringToIndex:[urlString length]-1];
	}
  
	// Borrowed from:
  // http://stackoverflow.com/questions/652300/using-md5-hash-on-a-string-in-cocoa
	const char *cStr = [urlString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X\
          %02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4],
          result[5], result[6], result[7],result[8], result[9], result[10],
          result[11],result[12], result[13], result[14], result[15]];
  
}

- (NSString *)pathToFile:(NSString *)file {
  return [storagePath_ stringByAppendingFormat:@"/%@/%@",
          kFileCacheFolder, file];
}

- (NSString *)pathToReference:(NSString *)reference {
  return [storagePath_ stringByAppendingFormat:@"/%@/%@",
          kReferenceCacheFolder, reference];
}

- (void)setStoragePath:(NSString *)path {
	storagePath_ = [path retain];
  
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
  
	BOOL isDirectory = NO;
	NSArray *directories =
  [NSArray arrayWithObjects:path,
   [path stringByAppendingPathComponent:kReferenceCacheFolder],
   [path stringByAppendingPathComponent:kFileCacheFolder],
   nil];
	for (NSString *directory in directories) {
		BOOL exists = [fileManager fileExistsAtPath:directory
                                    isDirectory:&isDirectory];
		if (exists && !isDirectory) {
			[NSException raise:@"FileExistsAtCachePath"
                  format:@"Cannot create a directory for the cache at '%@', \
       because a file already exists",
       directory];
		} else if (!exists) {
			[fileManager createDirectoryAtPath:directory
             withIntermediateDirectories:NO
                              attributes:nil
                                   error:nil];
			if (![fileManager fileExistsAtPath:directory]) {
				[NSException raise:@"FailedToCreateCacheDirectory"
                    format:@"Failed to create a directory for the cache at '%@'",
         directory];
			}
		}
	}
}

- (void)addItem:(IFCacheItem *)ci {
  @synchronized (self) {
    // Add a cache reference to memory
    [memoryStorage_ setValue:ci forKey:ci.key];
    
    // Add a cache reference to file storage
    [ci writeToFile:[self pathToReference:ci.key]];
  }
}

- (IFCacheItem *)find:(NSString *)key {
  @synchronized (self) {
    // Find the given key from memory storage first
    IFCacheItem *ci = [memoryStorage_ valueForKey:key];
    if (!ci && key) {
      // If not exist, find it from file storage
      ci = [[IFCacheItem alloc] initWithFilepath:[self pathToReference:key]];
      [memoryStorage_ setValue:ci forKey:key];
      [ci release];
    }
    
    return ci;
  }
}

- (void)removeItem:(NSString *)key {
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:[self pathToReference:key]
                                             error:&error];
  @synchronized (self) {
    [memoryStorage_ removeObjectForKey:key];
  }
}

- (BOOL)isCacheReachedMax {
  @synchronized (self) {
    return (memoryStorage_.count > maxSize_);
  }
}

- (void)emptyFolder:(NSString *)path {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *files = [manager contentsOfDirectoryAtPath:path
                                                error:&error];
  // If an error occurred, just do not delete them.
  if (!error) {
    for (NSString *file in files) {
      [manager removeItemAtPath:[path stringByAppendingPathComponent:file]
                          error:&error];
      if (error) {
        // an error occurred...
      }
    }
  }
}

- (void)clearCache {
  @synchronized (self) {
    // Delete reference and file folders and memory storage.
    [memoryStorage_ removeAllObjects];
    
    [self emptyFolder:
     [storagePath_ stringByAppendingPathComponent:kFileCacheFolder]];
    [self emptyFolder:
     [storagePath_ stringByAppendingPathComponent:kReferenceCacheFolder]];
  }
}

- (void)storeCache:(NSString *)key
         andMaxAge:(NSInteger)maxAge
           andData:(NSData *)data {
  // caching data is not high priority task, it will be executed in
  // background priority in the thread.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    // if the cache store has reached max, we don't store it or if key is nil
    // TODO: or removed oldest age cache item and make space for new cache
    //       object
    if ([self isCacheReachedMax] || key == nil) {
      return;
    }
    
    IFCacheItem *ci = [[IFCacheItem alloc] initWithKey:key
                                             andMaxAge:maxAge
                                           andFilePath:[self pathToFile:key]];
    
    // store the given data to proper file path
    if ([[NSFileManager defaultManager] createFileAtPath:ci.filePath
                                                contents:data
                                              attributes:nil]) {
      // only add if the file creation succeeded.
      [self addItem:ci];
    }
    [ci release];
  });
}

- (void)cacheImageForURL:(NSURL *)url
               andMaxAge:(NSInteger)maxAge
                andImage:(UIImage *)image {
  [self storeCacheForURL:url
               andMaxAge:maxAge
                 andData:UIImagePNGRepresentation(image)];
}

- (void)deleteCache:(NSString *)key {
  IFCacheItem *ci = [self find:key];
  if (ci && ci.filePath && ci.key) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:ci.filePath
                                               error:&error];
    // Ignore error from removing file.
    [self removeItem:ci.key];
  }
}

- (NSData *)cachedData:(NSString *)key {
  IFCacheItem *ci = [self find:key];
  if (ci) {
    // If item exist, if it's expired, delete it from both memory and file
    // storage and return nil
    if (ci.expire < [[NSDate date] timeIntervalSince1970]) {
      [self deleteCache:ci.key];
    } else {
      return [[NSFileManager defaultManager] contentsAtPath:ci.filePath];
    }
  }
  return nil;
}

- (UIImage *)cachedImageForURL:(NSURL *)url {
  NSData *data = [self cachedDataForURL:url];
  if (data) {
    return [UIImage imageWithData:data];
  }
  return nil;
}

- (void)storeCacheForURL:(NSURL *)url
               andMaxAge:(NSInteger)maxAge
                 andData:(NSData *)data {
  [self storeCache:[self.class keyForURL:url]
         andMaxAge:maxAge
           andData:data];
}

- (void)deleteCacheForURL:(NSURL *)url {
  [self deleteCache:[self.class keyForURL:url]];
}

- (NSData *)cachedDataForURL:(NSURL *)url {
  return [self cachedData:[self.class keyForURL:url]];
}

@end