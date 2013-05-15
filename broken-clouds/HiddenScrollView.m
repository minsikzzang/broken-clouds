//
//  HiddenScrollView.m
//  broken-clouds
//
//  Created by Min Kim on 5/14/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "HiddenScrollView.h"

@implementation HiddenScrollView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.delaysContentTouches = NO;
  }
  return self;
}

// Finds the UIViewController associated with the view, hopefully
- (UIViewController *)viewController:(UIView *)view {
  for (UIView* next = view; next; next = next.superview) {
    UIResponder* nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController*)nextResponder;
    }
  }
  return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  for (UIView *subview in [self subviews]) {
    CGPoint pt = CGPointMake(point.x - subview.frame.origin.x,
                             point.y - subview.frame.origin.y);
    if ([subview isKindOfClass:[UIScrollView class]] &&
        [subview pointInside:pt withEvent:event]) {
      UIViewController *vc = (UIViewController *)[self viewController:subview];
      NSLog(@"%lf, %lf", point.x, point.y);
      NSLog(@"%@", subview);
      NSLog(@"%@", vc);
      

      self.delaysContentTouches = YES;
      // [subview hitTest:point withEvent:event];
      // convPt = CGPointMake(pt.x - archiveVC.ofView.frame.origin.x, pt.y - archiveVC.ofView.frame.origin.y - OpenFlowViewOrigin.y);
      /*
      if([archiveVC.ofView pointInside:convPt withEvent:event]) {
        self.delaysContentTouches = NO;
      }
      else
        self.delaysContentTouches = YES;
      */
      break;
    } 
  }
  return [super hitTest:point withEvent:event];
}

@end
