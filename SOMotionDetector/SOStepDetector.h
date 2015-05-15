//
//  SOStepDetector.h
//  MotionDetection
//
//  Created by Artur on 5/15/15.
//  Copyright (c) 2015 Artur Mkrtchyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOStepDetector : NSObject

+ (instancetype)sharedInstance;

/**
 * Start accelerometer updates.
 * @param callback Will be called every time when new step is detected
 */
- (void)startDetectionWithUpdateBlock:(void(^)(NSError *error))callback;

/**
 * Stop motion manager accelerometer updates
 */
- (void)stopDetection;

@end
