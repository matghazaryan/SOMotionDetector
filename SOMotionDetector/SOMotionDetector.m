//
//  MotionDetecter.m
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

#import "SOMotionDetector.h"

CGFloat kMinimumSpeed        = 0.3f;
CGFloat kMaximumWalkingSpeed = 1.9f;
CGFloat kMaximumRunningSpeed = 7.5f;
CGFloat kMinimumRunningAcceleration = 3.5f;

@interface SOMotionDetector()

@property (strong, nonatomic) NSTimer *shakeDetectingTimer;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) SOMotionType previousMotionType;

#pragma mark - Accelerometer manager
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;


@end

@implementation SOMotionDetector

+ (SOMotionDetector *)sharedInstance
{
    static SOMotionDetector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationChangedNotification:)
                                                     name:LOCATION_DID_CHANGED_NOTIFICATION
                                                   object:nil];
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    return self;
}

+ (BOOL)motionHardwareAvailable
{
    static BOOL isAvailable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isAvailable = [CMMotionActivityManager isActivityAvailable];
    });
    
    return isAvailable;
}

#pragma mark - Public Methods
- (void)startDetection
{
    [[SOLocationManager sharedInstance] start];
    
    self.shakeDetectingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                                target:self
                                                              selector:@selector(detectShaking)
                                                              userInfo:Nil
                                                               repeats:YES];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
         _acceleration = accelerometerData.acceleration;
         [self calculateMotionType];
         dispatch_async(dispatch_get_main_queue(), ^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
             if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:accelerationChanged:)]) {
                 [self.delegate motionDetector:self accelerationChanged:self.acceleration];
             }
#pragma GCC diagnostic pop
             
             
             if (self.accelerationChangedBlock) {
                 self.accelerationChangedBlock (self.acceleration);
             }
         });
     }];
    
    if (self.useM7IfAvailable && [SOMotionDetector motionHardwareAvailable]) {
        if (!self.motionActivityManager) {
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        }
        
        [self.motionActivityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (activity.walking) {
                    _motionType = MotionTypeWalking;
                } else if (activity.running) {
                    _motionType = MotionTypeRunning;
                } else if (activity.automotive) {
                    _motionType = MotionTypeAutomotive;
                } else if (activity.stationary || activity.unknown) {
                    _motionType = MotionTypeNotMoving;
                }
                
                // If type was changed, then call delegate method
                if (self.motionType != self.previousMotionType) {
                    self.previousMotionType = self.motionType;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                    if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:motionTypeChanged:)]) {
                        [self.delegate motionDetector:self motionTypeChanged:self.motionType];
                    }
#pragma GCC diagnostic pop
                    
                    if (self.motionTypeChangedBlock) {
                        self.motionTypeChangedBlock (self.motionType);
                    }
                }
            });

        }];
    }
}

- (void)stopDetection
{
    [self.shakeDetectingTimer invalidate];
    self.shakeDetectingTimer = nil;
    
    [[SOLocationManager sharedInstance] stop];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionActivityManager stopActivityUpdates];
}

#pragma mark - Customization Methods
- (void)setMinimumSpeed:(CGFloat)speed
{
    kMinimumSpeed = speed;
}

- (void)setMaximumWalkingSpeed:(CGFloat)speed
{
    kMaximumWalkingSpeed = speed;
}

- (void)setMaximumRunningSpeed:(CGFloat)speed
{
    kMaximumRunningSpeed = speed;
}

- (void)setMinimumRunningAcceleration:(CGFloat)acceleration
{
    kMinimumRunningAcceleration = acceleration;
}
#pragma mark - Private Methods
- (void)calculateMotionType
{
    if (self.useM7IfAvailable && [SOMotionDetector motionHardwareAvailable]) {
        return;
    }
    
    if (_currentSpeed < kMinimumSpeed) {
        _motionType = MotionTypeNotMoving;
    } else if (_currentSpeed <= kMaximumWalkingSpeed) {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeWalking;
    } else if (_currentSpeed <= kMaximumRunningSpeed) {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeAutomotive;
    } else {
        _motionType = MotionTypeAutomotive;
    }
    
    // If type was changed, then call delegate method
    if (self.motionType != self.previousMotionType) {
        self.previousMotionType = self.motionType;
        
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:motionTypeChanged:)]) {
                [self.delegate motionDetector:self motionTypeChanged:self.motionType];
            }
#pragma GCC diagnostic pop
            
            if (self.motionTypeChangedBlock) {
                self.motionTypeChangedBlock (self.motionType);
            }
        });
    }
}

- (void)detectShaking
{
    //Array for collecting acceleration for last one seconds period.
    static NSMutableArray *shakeDataForOneSec = nil;
    //Counter for calculating completion of one second interval
    static float currentFiringTimeInterval = 0.0f;
    
    currentFiringTimeInterval += 0.01f;
    if (currentFiringTimeInterval < 1.0f) {// if one second time intervall not completed yet
        if (!shakeDataForOneSec)
            shakeDataForOneSec = [NSMutableArray array];
        
        // Add current acceleration to array
        NSValue *boxedAcceleration = [NSValue value:&_acceleration withObjCType:@encode(CMAcceleration)];
        [shakeDataForOneSec addObject:boxedAcceleration];
    } else {
        // Now, when one second was elapsed, calculate shake count in this interval. If there will be at least one shake then
        // we'll determine it as shaked in all this one second interval.
        
        int shakeCount = 0;
        for (NSValue *boxedAcceleration in shakeDataForOneSec) {
            CMAcceleration acceleration;
            [boxedAcceleration getValue:&acceleration];
         
            /*********************************
             *       Detecting shaking
             *********************************/
            double accX_2 = powf(acceleration.x,2);
            double accY_2 = powf(acceleration.y,2);
            double accZ_2 = powf(acceleration.z,2);
            
            double vectorSum = sqrt(accX_2 + accY_2 + accZ_2);
            
            if (vectorSum >= kMinimumRunningAcceleration) {
                shakeCount++;
            }
            /*********************************/
        }
        _isShaking = shakeCount > 0;
        
        shakeDataForOneSec = nil;
        currentFiringTimeInterval = 0.0f;
    }
}

#pragma mark - LocationManager notification handler
- (void)handleLocationChangedNotification:(NSNotification *)note
{
    self.currentLocation = [SOLocationManager sharedInstance].lastLocation;
    _currentSpeed = self.currentLocation.speed;
    if (_currentSpeed < 0) {
        _currentSpeed = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:locationChanged:)]) {
            [self.delegate motionDetector:self locationChanged:self.currentLocation];
        }
#pragma GCC diagnostic pop
        
        if (self.locationChangedBlock) {
            self.locationChangedBlock (self.currentLocation);
        }
    });

    [self calculateMotionType];
}
@end
