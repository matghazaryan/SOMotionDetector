SOMotionDetector
================

Simple library to detect motion for iOS by <b> arturdev </b>.

Based on location updates and acceleration.

###Requierments
iOS > 6.0 

Compatible with <b>iOS 7</b>

<b>Works on all iOS devices (i.e. not need M7 chip)</b>

<img src="https://raw.github.com/SocialObjects-Software/SOMotionDetector/master/MotionDetection/screenshot.PNG" width=320>


USAGE
=====
Copy <b>SOMotionDetector</b> folder to your project.

Link <b>CoreMotion.framework</b>, <b>CoreLocation.framework</b>.

Import <b>"SOMotionDetector.h"</b> file and implement <br><SOMotionDetectorDelegate></b> protocol.

```ObjC
#import "SOMotionDetector.h
@interface ViewController ()<SOMotionDetectorDelegate>

@end
```

Set SOMotionDetector's delegate to self
```ObjC
[SOMotionDetector sharedInstance].delegate = self;
```

Implement delegate methods 
```ObjC
- (void)motionDetector:(SOMotionDetector *)motionDetector motionTypeChanged:(SOMotionType)motionType
{

}

- (void)motionDetector:(SOMotionDetector *)motionDetector locationChanged:(CLLocation *)location
{

}

- (void)motionDetector:(SOMotionDetector *)motionDetector accelerationChanged:(CMAcceleration)acceleration
{
    
}
```

You are done! 

Now to start detection motion just call
```ObjC 
[[SOMotionDetector sharedInstance] startDetection];
```

To stop detection call
```ObjC 
[[SOMotionDetector sharedInstance] stopDetection];
```  

###Detecting motion types
```ObjC
typedef enum
{
  MotionTypeNotMoving = 1,
  MotionTypeWalking,
  MotionTypeRunning,
  MotionTypeAutomotive
} SOMotionType;
```

CUSTOMIZATION
=============
```ObjC

/**
 * Set this parameter to YES if you want to use M7 chip to detect more exact motion type. By default is No.
 * Set this parameter before calling startDetection method.
 * Available only on devices that have M7 chip. At this time only the iPhone 5S, the iPad Air and iPad mini with retina display have the M7 coprocessor.
 */
@property (nonatomic) BOOL useM7IfAvailable;

/**
 *@param speed  The minimum speed value less than which will be considered as not moving state
 */
- (void)setMinimumSpeed:(CGFloat)speed;

/**
 *@param speed  The maximum speed value more than which will be considered as running state
 */
- (void)setMaximumWalkingSpeed:(CGFloat)speed;

/**
 *@param speed  The maximum speed value more than which will be considered as automotive state
 */
- (void)setMaximumRunningSpeed:(CGFloat)speed;

/**
 *@param acceleration  The minimum acceleration value less than which will be considered as non shaking state
 */
- (void)setMinimumRunningAcceleration:(CGFloat)acceleration;

```

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries installation in your projects.

#### Podfile

```ruby
pod "SOMotionDetector", "~> 1.0.0"
```

<h2>LICENSE</h2>
SOMotionDetector is under MIT License (see LICENSE file)
