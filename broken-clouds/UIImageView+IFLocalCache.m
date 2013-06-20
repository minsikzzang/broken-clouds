//
//  UIImageView+IFLocalCache.m
//  broken-clouds
//
//  Created by Min Kim on 6/6/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "UIImageView+IFLocalCache.h"
#import <objc/runtime.h>
#import "AFImageRequestOperation.h"
#import "IFLocalCache.h"

const NSInteger kIFCacheMaxAge = 60 * 60 * 24 * 30;

static char kIFImageRequestOperationObjectKey;

@interface UIImageView (_IFLocalCache)
@property (readwrite, nonatomic, strong, setter = if_setImageRequestOperation:) AFImageRequestOperation *if_imageRequestOperation;
@end

@implementation UIImageView (_IFLocalCache)
@dynamic if_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (IFLocalCache)

- (AFHTTPRequestOperation *)if_imageRequestOperation {
  return (AFHTTPRequestOperation *)objc_getAssociatedObject(self,
                                                            &kIFImageRequestOperationObjectKey);
}

- (void)if_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
  objc_setAssociatedObject(self, &kIFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)if_sharedImageRequestOperationQueue {
  static NSOperationQueue *_if_imageRequestOperationQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _if_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
    [_if_imageRequestOperationQueue
     setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
  });
  
  return _if_imageRequestOperationQueue;
}

+ (IFLocalCache *)if_sharedImageCache {
  static IFLocalCache *_if_imageCache = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _if_imageCache = [[IFLocalCache alloc] init];
    _if_imageCache.maxSize = 2048;
  });
  
  return _if_imageCache;
}

#pragma mark -

- (void)setIFImageWithURL:(NSURL *)url {
  [self setIFImageWithURL:url placeholderImage:nil];
}

- (void)setIFImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  
  [self setIFImageWithURLRequest:request
                placeholderImage:placeholderImage
                         success:nil
                         failure:nil];
}

- (void)setIFImageWithURLRequest:(NSURLRequest *)urlRequest
                placeholderImage:(UIImage *)placeholderImage
                         success:(void (^)(NSURLRequest *request,
                                         NSHTTPURLResponse *response,
                                         UIImage *image))success
                         failure:(void (^)(NSURLRequest *request,
                                         NSHTTPURLResponse *response,
                                         NSError *error))failure {
  [self cancelIFImageRequestOperation];
  
  UIImage *cachedImage = [[[self class] if_sharedImageCache]
                          cachedImageForURL:[urlRequest URL]];
  if (cachedImage) {
    if (success) {
      success(nil, nil, cachedImage);
    } else {
      self.image = cachedImage;
    }
    
    self.if_imageRequestOperation = nil;
  } else {
    self.image = placeholderImage;
    
    AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      if ([urlRequest isEqual:[self.if_imageRequestOperation request]]) {
        if (success) {
          success(operation.request, operation.response, responseObject);
        } else if (responseObject) {
          self.image = responseObject;
        }
        
        if (self.if_imageRequestOperation == operation) {
          self.if_imageRequestOperation = nil;
        }
      }
      
      [[[self class] if_sharedImageCache] cacheImageForURL:[urlRequest URL]
                                                 andMaxAge:kIFCacheMaxAge
                                                  andImage:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if ([urlRequest isEqual:[self.if_imageRequestOperation request]]) {
        if (failure) {
          failure(operation.request, operation.response, error);
        }
        
        if (self.if_imageRequestOperation == operation) {
          self.if_imageRequestOperation = nil;
        }
      }
    }];
    
    self.if_imageRequestOperation = requestOperation;
    
    [[[self class] if_sharedImageRequestOperationQueue]
     addOperation:self.if_imageRequestOperation];
  }
}

- (void)cancelIFImageRequestOperation {
  [self.if_imageRequestOperation cancel];
  self.if_imageRequestOperation = nil;
}

@end
