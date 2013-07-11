//
//  IFTrackableScrollView.m
//  broken-clouds
//
//  Created by Min Kim on 6/21/13.
//  Copyright (c) 2013 iFactory Lab. All rights reserved.
//

#import "IFTrackableScrollView.h"
#import "BasicTypes.h"

@implementation IFTrackableScrollView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    
  }
  return self;
}

- (void)dealloc {
  SAFE_RELEASE(children_)
  [super dealloc];
}

- (void)setContentOffset:(CGPoint)contentOffset {
  [super setContentOffset:contentOffset];
  
  // NSLog(@"%lf, %lf", contentOffset.x, contentOffset.y);
  for (UIView *child in children_) {
  //  CGRect fr = child.frame;
  //  fr.origin.y -= contentOffset.y;
  //  child.frame = CGRectMake(FRX(fr), FRY(fr), FRW(fr), FRH(fr));
  }
}

- (void)addChildView:(UIView *)view {
//  if (children_ == nil)
//    children_ = [[NSMutableArray alloc] init];
  
//  [view removeFromSuperview];
//  [children_ addObject:view];
}

@end
