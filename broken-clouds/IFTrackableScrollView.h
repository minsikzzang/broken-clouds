//
//  IFTrackableScrollView.h
//  broken-clouds
//
//  Created by Min Kim on 6/21/13.
//  Copyright (c) 2013 iFactory Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IFTrackableScrollView : UIScrollView {
@private
  NSMutableArray *children_;
}

- (void)addChildView:(UIView *)view;

@end
