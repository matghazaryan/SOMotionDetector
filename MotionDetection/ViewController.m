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
#import "SOStepDetector.h"

@interface ViewController ()<SOMotionDetectorDelegate>
{
    int stepCount;
}
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *isShakingLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    __weak ViewController *weakSelf = self;
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
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
        
        weakSelf.motionTypeLabel.text = type;
    };
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        weakSelf.speedLabel.text = [NSString stringWithFormat:@"%.2f km/h",[SOMotionDetector sharedInstance].currentSpeed * 3.6f];
    };
    
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {
        BOOL isShaking = [SOMotionDetector sharedInstance].isShaking;
        weakSelf.isShakingLabel.text = isShaking ? @"shaking":@"not shaking";
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [SOMotionDetector sharedInstance].useM7IfAvailable = YES; //Use M7 chip if available, otherwise use lib's algorithm
    }
    
    [[SOMotionDetector sharedInstance] startDetection];
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        stepCount++;
        self.stepCountLabel.text = [NSString stringWithFormat:@"Step count: %d", stepCount];
    }];
}

@end
