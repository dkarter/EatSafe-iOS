//
//  SafeToEatViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 3/3/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "SafeToEatViewController.h"
#import "SearchViewController.h"

@interface SafeToEatViewController () <CLLocationManagerDelegate>

- (IBAction)searchButtonClicked:(UIButton *)sender;

@end

@implementation SafeToEatViewController {
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    int radius;
    CLLocation *currentLocation;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];

    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)getLocationClicked:(id)sender {
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [manager startUpdatingLocation];
}

- (IBAction)stopMonitoringLocation:(id)sender {
    [manager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location :(");
}

- (void)locationManager:(CLLocationManager *)locManager didUpdateLocations:(NSArray *)locations {
    currentLocation = locations[0];
    if (currentLocation) {
        NSLog(@"%@",[NSString stringWithFormat:@"Latitude: %f", currentLocation.coordinate.latitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"Longitude: %f", currentLocation.coordinate.longitude]);
        [locManager stopUpdatingLocation];
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && [placemarks count] > 0) {
//                placemark = placemarks.lastObject;
//                self.addressLabel.text = [NSString stringWithFormat:@"Address:\n%@ %@\n%@ %@\n%@\n%@",
//                                          placemark.thoroughfare,
//                                          placemark.subThoroughfare,
//                                          placemark.postalCode,
//                                          placemark.locality,
//                                          placemark.administrativeArea,
//                                          placemark.country];
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        }];

    }

    
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SearchViewController *svc = (SearchViewController *)segue.destinationViewController;
    svc.location = [[CLLocation alloc] initWithLatitude:41.888477 longitude:-87.635332]; //currentLocation;
    svc.focusSearch = [segue.identifier isEqualToString:@"SearchSegue"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)searchButtonClicked:(UIButton *)sender {
    
}
@end
