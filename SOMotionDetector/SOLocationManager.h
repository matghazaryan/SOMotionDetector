//
//  SOLocationManager.h
//  Heat
//
//  Created by Artur Mkrtchyan on 12/19/13.
//  Copyright (c) 2013 Artur Mkrtchyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define LOCATION_DID_CHANGED_NOTIFICATION @"LOCATION_DID_CHANGED_NOTIFICATION"
#define LOCATION_DID_FAILED_NOTIFICATION @"LOCATION_DID_FAILED_NOTIFICATION"

typedef enum
{
    LocationManagerTypeNone = 0x00,
    LocationManagerTypeStandart = 0x10,
    LocationManagerTypeSignificant = 0x01,
    LocationManagetTypeStandartAndSignificant = 0x11
} SOLocationManagerType;

@interface SOLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation* lastLocation;
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;

+ (SOLocationManager *)sharedInstance;

/**
 *  Indicates in whether of LocationManagetType state is now the location manager's shared instance.
 */
@property (nonatomic) SOLocationManagerType locationType;

/**
 * Start Location Update
 */
- (void)start;

/**
 * Start Significant Location Update
 */
- (void)startSignificant;

/**
 * Stop Location Update only (this means, if significant update is started, then will be stopped standart location updates only).
 */
- (void)stop;

/**
 * Stop Significant Location Update (only)
 */
- (void)stopSignificant;

@end
