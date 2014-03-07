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

@interface SOMotionDetector()<CLLocationManagerDelegate>

@property (strong, nonatomic) NSTimer *shakeDetectingTimer;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) SOMotionType previouseMotionType;

#pragma mark - Accelerometer manager
@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation SOMotionDetector

+ (SOMotionDetector *)sharedInstance
{
    static SOMotionDetector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationChangedNotification:) name:LOCATION_DID_CHANGED_NOTIFICATION object:nil];
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    return self;
}

#pragma mark - Public Methods
- (void)startDetection
{
    [[SOLocationManager sharedInstance] start];
    
    self.shakeDetectingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(detectShaking) userInfo:Nil repeats:YES];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
     {
         _acceleration = accelerometerData.acceleration;
         [self calculateMotionType];
         dispatch_async(dispatch_get_main_queue(), ^{
             if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:accelerationChanged:)])
             {
                 [self.delegate motionDetector:self accelerationChanged:self.acceleration];
             }
         });
     }];
}

- (void)stopDetection
{
    [self.shakeDetectingTimer invalidate];
    self.shakeDetectingTimer = nil;
    
    [[SOLocationManager sharedInstance] stop];
    [self.motionManager stopAccelerometerUpdates];
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
    if (self.currentLocation.speed < kMinimumSpeed)
    {
        _motionType = MotionTypeNotMoving;
    }
    else if (self.currentLocation.speed <= kMaximumWalkingSpeed)
    {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeWalking;
    }
    else if (self.currentLocation.speed <= kMaximumRunningSpeed)
    {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeAutomotive;
    }
    else
    {
        _motionType = MotionTypeAutomotive;
    }
    
    // If type was changed, then call delegate method
    if (self.motionType != self.previouseMotionType)
    {
        self.previouseMotionType = self.motionType;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:motionTypeChanged:)])
        {
            [self.delegate motionDetector:self motionTypeChanged:self.motionType];
        }
    }
}

- (void)detectShaking
{
    //Array for collecting acceleration for last one seconds period.
    static NSMutableArray *shakeDataForTwoOneSec = nil;
    //Counter for calculating complition of one second interval
    static float currentFiringTimeInterval = 0.0f;
    
    currentFiringTimeInterval += 0.01f;
    if (currentFiringTimeInterval < 1.0f) // if one second time intervall not completed yet
    {
        if (!shakeDataForTwoOneSec)
            shakeDataForTwoOneSec = [NSMutableArray array];
        
        // Add current acceleration to array
        NSValue *boxedAcceleration = [NSValue value:&_acceleration withObjCType:@encode(CMAcceleration)];
        [shakeDataForTwoOneSec addObject:boxedAcceleration];
    }
    else
    {
        // Now, when one second was elapsed, calculate shake count in this interval. If the will be at least one shake then
        // we'll determine it as shaked in all this one second interval.
        
        int shakeCount = 0;
        for (NSValue *boxedAcceleration in shakeDataForTwoOneSec) {
            CMAcceleration acceleration;
            [boxedAcceleration getValue:&acceleration];
         
            /*********************************
             *       Detecting shaking
             *********************************/
            double accX = fabs(acceleration.x);
            double accY = fabs(acceleration.y);
            double accZ = fabs(acceleration.z);
            
            if (!(accX < kMinimumRunningAcceleration && accY < kMinimumRunningAcceleration && accZ < kMinimumRunningAcceleration))
            {
                shakeCount++;
            }
            /*********************************/
        }
        _isShaking = shakeCount > 0;
        
        
        shakeDataForTwoOneSec = nil;
        currentFiringTimeInterval = 0.0f;
    }
}

#pragma mark - LocationManager notification handler
- (void)handleLocationChangedNotification:(NSNotification *)note
{
    self.currentLocation = [SOLocationManager sharedInstance].lastLocation;
    _currentSpeed = self.currentLocation.speed;
    if (_currentSpeed < 0)
        _currentSpeed = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:locationChanged:)])
    {
        [self.delegate motionDetector:self locationChanged:self.currentLocation];
    }
    
    [self calculateMotionType];
}
@end
