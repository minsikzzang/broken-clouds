//
//  UIDebugger.h
//  weather-shot
//
//  Created by Min Kim on 4/27/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDebugger : NSObject {
@private
  UITextView *textView_;
}

@property (nonatomic, retain) UIView *parent;

- (void)attach;
- (void)debug:(NSString *)log;

@end
