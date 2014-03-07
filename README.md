SOMotionDetector
================

Simple library to detect motion for iOS by <b> arturdev </b>.



USAGE
=====
Copy <b>SOMotionDetector</b> folder to your project.

Link <b>CoreMotion.framework</b>, <b>CoreLocation.framework</b>.

Import <b>SOMotionDetector.h"</b> file and implement <br><SOMotionDetectorDelegate></b> protocol.

<pre>
#import "SOMotionDetector.h" 
@interface ViewController ()<SOMotionDetectorDelegate>

@end
</pre>

Set SOMotionDetector's delegate to self
<pre>
[SOMotionDetector sharedInstance].delegate = self;
</pre>

Implement delegate methods 
<pre>
- (void)motionDetector:(SOMotionDetector *)motionDetector motionTypeChanged:(SOMotionType)motionType
{

}

- (void)motionDetector:(SOMotionDetector *)motionDetector locationChanged:(CLLocation *)location
{

}

- (void)motionDetector:(SOMotionDetector *)motionDetector accelerationChanged:(CMAcceleration)acceleration
{
    
}
</pre>

You are done! 

Just call `[[SOMotionDetector sharedInstance] startDetection];` when you want to start detection
and `[[SOMotionDetector sharedInstance] stopDetection];`  when you want to stop detection.
