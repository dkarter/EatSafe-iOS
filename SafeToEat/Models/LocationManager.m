//
//  LocationManager.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/9/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager {
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    int radius;
    CLLocation *location;
}

- (id)init {
    self = [super init];
    
    if (self) {
        //initial coordinate just so we don't crash
        location = [[CLLocation alloc] init];
        //setup location manager
        manager = [[CLLocationManager alloc] init];
        [manager setDelegate:self];
        [manager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [manager setDistanceFilter:10.0f];
        [manager startUpdatingLocation];
        
    }
    
    return self;
}

- (id)initWithDelegate:(id<NSObject, ESLocationManagerDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (void)startUpdatingLocation {
    [manager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)locManager didUpdateLocations:(NSArray *)locations {
    location = locations[0];
    if (location) {
        [self.delegate didRecieveLocationUpdate:location];
        
        NSLog(@"%@",[NSString stringWithFormat:@"Latitude: %f", location.coordinate.latitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"Longitude: %f", location.coordinate.longitude]);
    }
}

- (CLLocation *)lastLocation {
    return location;
}

@end
