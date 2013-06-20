//
//  BasicTypes.h
//  weather-shot
//
//  Created by Min Kim on 4/17/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//


// RGB macros
#define RGB(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define DegreesToRadians(x) (M_PI * x / 180.0)

// Safe release
#define SAFE_RELEASE(x) if (x) { [x release]; x = nil; }

#define SAFE_RELEASE_RETAIN(x, y)	{ if (x)	{ [x release];	x = nil; } x = [y retain]; }

// Check NSNull and convert to NSInteger or NSFloat
#define TO_NSINT(x, y)      if (y && [NSNull null] != y) {x = [y intValue];} else {x = 0;}
#define TO_NSINT_(x, y, z)  if (y && [NSNull null] != y) {x = [y intValue];} else {x = z;}
#define TO_NSFLOAT(x, y)    if (y && [NSNull null] != y) {x = [y floatValue];} else {x = 0;}
#define TO_BOOL(x, y)       if (y && [NSNull null] != y) {x = [y boolValue];} else {x = NO;}
#define TO_STRING(x, y)     if (y && [NSNull null] != y) {x = y;} else {x = nil;}
#define TO_ARRAY(x, y)      if (y) {x = y;} else {x = nil;}

// UIBar Back button
#define SET_UIBAR_BACK_BUTTON(x)        UIBarButtonItem *bt = [[UIBarButtonItem alloc]initWithTitle:x \
style:UIBarButtonItemStylePlain \
target:nil \
action:nil]; \
self.navigationItem.backBarButtonItem = bt; \
[bt release];

#define SET_UIBAR_BACK_BUTTON_EX(a, x)        UIBarButtonItem *bt = [[UIBarButtonItem alloc]initWithTitle:x \
style:UIBarButtonItemStylePlain \
target:nil \
action:nil]; \
a.backBarButtonItem = bt; \
[bt release];

// Alert View with OK
#define SHOW_ALERT_OK(x, y)   { \
UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:x \
message:y \
delegate:nil \
cancelButtonTitle:@"OK" otherButtonTitles:nil]; \
[alertView show]; \
[alertView release]; }

#define SHOW_ALERT_OK_EX(x, y, z)   { \
UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:x \
message:y \
delegate:z \
cancelButtonTitle:@"OK" otherButtonTitles:nil]; \
[alertView show]; \
[alertView release]; }

#define SHOW_ALERT_OK_YESNO(x, y, z)   { \
UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:x \
message:y \
delegate:z \
cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil]; \
[alertView show]; \
[alertView release]; }

#define SHOULDNT_BE_REACHED_HERE   \
NSLog(@"Shouldn't be reached here");  \
NSAssert(YES, @"Shouldn't be reached here"); \

// Simple swap algorithm without using third variable.
#define SWAP(x, y)  { \
x = x + y;  \
y = x - y;  \
x = x - y;  \
}

#define HALF(x)   ((x / 2.0))

#define STOP_NSTIMER(x) \
if (x) {  \
if ([x isValid]) {  \
[x invalidate]; \
} \
x = nil;  \
}

#define START_NSTIMER(x, y, z) \
if (!x) { \
x = [NSTimer scheduledTimerWithTimeInterval:y \
target:self  \
selector:@selector(z)  \
userInfo:nil \
repeats:NO];  \
}

#define START_NSTIMER_(x, y, z, w) \
if (!x) { \
x = [NSTimer scheduledTimerWithTimeInterval:y \
target:self  \
selector:@selector(z)  \
userInfo:nil \
repeats:w];  \
}


#define ADD_OBSERVER(x, y, z, w) \
[[NSNotificationCenter defaultCenter] addObserver:x \
selector:@selector(y)  \
name:z \
object:w];

#define REMOVE_OBSERVER(x, y, z) \
[[NSNotificationCenter defaultCenter] removeObserver:x  \
name:y  \
object:z];

#define PLATFORM_IPAD \
([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define PLATFORM_IPHONE \
([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define FRX(z) z.origin.x
#define FRY(x) x.origin.y
#define FRW(x) x.size.width
#define FRH(x) x.size.height

#define DISTANCE_BETWEEN(x, y) \
MKMetersBetweenMapPoints(MKMapPointForCoordinate(x), MKMapPointForCoordinate(y));


