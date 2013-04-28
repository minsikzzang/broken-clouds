//
//  UIDebugger.m
//  weather-shot
//
//  Created by Min Kim on 4/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "UIDebugger.h"
#import "BasicTypes.h"

@implementation UIDebugger

@synthesize parent;

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)attach {
  textView_ = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 300.0)];
  textView_.backgroundColor = [UIColor clearColor];
  textView_.textColor = [UIColor blackColor];
  textView_.clipsToBounds = YES;
  
  CGPoint scrollPoint = textView_.contentOffset;
  scrollPoint.y= scrollPoint.y + 10;
  [textView_ setContentOffset:scrollPoint animated:YES];
  
  textView_.alpha = 0.6;
  [parent addSubview:textView_];
}

- (void)dealloc {
  SAFE_RELEASE(textView_)
  [super dealloc];
}

- (void)debug:(NSString *)log {
  textView_.text = [textView_.text stringByAppendingFormat:@"\n%@", log];
  NSLog(@"%@", textView_.text);
}

@end
