//
//  UIImage+Resizing.m
//  broken-clouds
//
//  Created by Min Kim on 6/3/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "UIImage+Resizing.h"

@implementation UIImage (Resize)

- (UIImage *)scaleToSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0.0, size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
  CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height),
                     self.CGImage);
  
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
  UIGraphicsEndImageContext();
  
  return scaledImage;
}

@end
