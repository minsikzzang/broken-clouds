//
//  GrayscaleContrastFilter.h
//  broken-clouds
//
//  Created by Min Kim on 6/9/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "GPUImageFilter.h"

extern NSString *const kGrayscaleContrastFragmentShaderString;

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)
 */
@interface GrayscaleContrastFilter : GPUImageFilter
{
  GLint intensityUniform;
	GLint slopeUniform;
}

@property(readwrite, nonatomic) CGFloat intensity;

@end
