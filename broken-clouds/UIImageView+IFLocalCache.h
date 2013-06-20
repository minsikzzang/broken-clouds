//
//  UIImageView+IFLocalCache.h
//  broken-clouds
//
//  Created by Min Kim on 6/6/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageView (IFLocalCache)

- (void)setIFImageWithURL:(NSURL *)url;
- (void)setIFImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage;
- (void)setIFImageWithURLRequest:(NSURLRequest *)urlRequest
                placeholderImage:(UIImage *)placeholderImage
                         success:(void (^)(NSURLRequest *request,
                                           NSHTTPURLResponse *response,
                                           UIImage *image))success
                         failure:(void (^)(NSURLRequest *request,
                                           NSHTTPURLResponse *response,
                                           NSError *error))failure;
- (void)cancelIFImageRequestOperation;

@end
