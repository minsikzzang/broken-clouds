//
//  IFCacheItem.m
//  broken-clouds
//
//  Created by Min Kim on 6/4/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "IFCacheItem.h"
#import "BasicTypes.h"
#import "JSONKit.h"

@implementation IFCacheItem

@synthesize filePath = filePath_;
@synthesize key = key_;
@synthesize expire = expire_;

- (id)initWithKey:(NSString *)key
        andMaxAge:(NSInteger)maxAge
      andFilePath:(NSString *)filePath {
  self = [super init];
  if (self) {
    self.key = key;
    self.filePath = filePath;
    expire_ = [[NSDate date] timeIntervalSince1970] + (long)maxAge;
  }
  return self;
}

- (id)initWithFilepath:(NSString *)path {
  self = [self init];
  if (self) {
    NSError *error = nil;
    NSString *buf =
      [[NSString alloc] initWithContentsOfFile:path
                                      encoding:NSUTF8StringEncoding
                                         error:&error];
    
    NSDictionary *ref = [buf objectFromJSONString];
    self.key = [ref valueForKey:@"key"];
    self.filePath = [ref valueForKey:@"filePath"];
    expire_ = [[ref valueForKey:@"expire"] longLongValue];
    
    ref = nil;
    SAFE_RELEASE(buf)
  }
  return self;
}

- (BOOL)writeToFile:(NSString *)path {
  NSString *data =
    [NSString stringWithFormat:@"{\"key\":\"%@\",\"expire\":\"%ld\",\"filePath\":\"%@\"}",
     key_, expire_, filePath_];
  NSLog(@"fp: %@", path);
  
  return [[NSFileManager defaultManager]
          createFileAtPath:path
          contents:[data dataUsingEncoding:NSUTF8StringEncoding]
          attributes:nil];
}


- (void)dealloc {
  SAFE_RELEASE(key_)
  SAFE_RELEASE(filePath_)
  [super dealloc];
}

@end
