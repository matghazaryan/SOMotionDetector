//
//  ViewController.m
//  MotionDetection
//
// The MIT License (MIT)
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "ViewController.h"
#import "SOMotionDetector.h"

@interface ViewController ()<SOMotionDetectorDelegate>
{

}
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *isShakingLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [SOMotionDetector sharedInstance].delegate = self;
    [[SOMotionDetector sharedInstance] startDetection];

}

#pragma mark - MotiionDetector Delegate
- (void)motionDetector:(SOMotionDetector *)motionDetector motionTypeChanged:(SOMotionType)motionType
{
    NSString *type = @"";
    switch (motionType) {
        case MotionTypeNotMoving:
            type = @"Not moving";
            break;
        case MotionTypeWalking:
            type = @"Walking";
            break;
        case MotionTypeRunning:
            type = @"Running";
            break;
        case MotionTypeAutomotive:
            type = @"Automotive";
            break;
    }
    
    self.motionTypeLabel.text = type;
}

- (void)motionDetector:(SOMotionDetector *)motionDetector locationChanged:(CLLocation *)location
{
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f km/h",motionDetector.currentSpeed * 3.6f];
}

- (void)motionDetector:(SOMotionDetector *)motionDetector accelerationChanged:(CMAcceleration)acceleration
{
    BOOL isShaking = motionDetector.isShaking;
    self.isShakingLabel.text = isShaking ? @"shaking":@"not shaking";
    
    NSLog(@"%.2f   %.2f   %.2f",fabs(acceleration.x),fabs(acceleration.y),fabs(acceleration.z));
}

@end
