//
//  LocationManager.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/9/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ESLocationManagerDelegate <NSObject>

- (void)didRecieveLocationUpdate:(CLLocation *)location;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>


@property (strong, nonatomic, readonly) CLLocation *lastLocation;

@property (strong, nonatomic) id<NSObject, ESLocationManagerDelegate> delegate;

- (id)initWithDelegate:(id<NSObject, ESLocationManagerDelegate>)delegate;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
