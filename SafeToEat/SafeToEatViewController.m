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

////properties
//@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
//@property (strong, nonatomic) NSArray *currentLocationHealthInspectionsData;


////actions
//- (IBAction)getLocationClicked:(id)sender;
//- (IBAction)stopMonitoringLocation:(id)sender;
//- (IBAction)getHealthInspections:(id)sender;
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
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];

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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = locations[0];
    if (currentLocation) {
        NSLog(@"%@",[NSString stringWithFormat:@"Latitude: %f", currentLocation.coordinate.latitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"Longitude: %f", currentLocation.coordinate.longitude]);

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


//- (IBAction)getHealthInspections:(id)sender {
////    NSString *kHealthInspectionsURL = @"https://data.cityofchicago.org/resource/cnfp-tsxc.json?$where=within_circle(location, %f, %f, %d)";
////
////    NSString *urlString = [NSString stringWithFormat:kHealthInspectionsURL,
////                           currentLocation.coordinate.latitude,
////                           currentLocation.coordinate.longitude,
////                           150];
////    
////    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    NSURL *url = [[NSURL alloc] initWithString:urlString];
////    
////    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
////    [urlRequest addValue:@"Qt9CMe5t8uUx6rHu0PRCRhmTq" forHTTPHeaderField:@"X-App-Token"];
////
////    [NSURLConnection sendAsynchronousRequest:urlRequest
////                                       queue:[[NSOperationQueue alloc] init]
////                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
////                               if (!connectionError) {
////                                   NSError *localError = nil;
////                                   self.currentLocationHealthInspectionsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
////                                   
////                                   if (!localError) {
////                                       //NSLog(@"%@", parsedObject);
////                                       UIStoryboard *storyboard = self.navigationController.storyboard;
////                                       PlacesViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"PlacesView"];
////                                       pvc.healthInspectionData = self.currentLocationHealthInspectionsData;
////
////                                       [self.navigationController pushViewController:pvc animated:YES];
////                                   } else {
////                                       NSLog(@"Parse Error: %@", localError);
////                                   }
////                                   
////                               } else {
////                                   NSLog(@"Error: %@", connectionError.debugDescription);
////                               }
////
////    }];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SearchViewController *svc = (SearchViewController *)segue.destinationViewController;
    
    svc.focusSearch = [segue.identifier isEqualToString:@"SearchSegue"];
    
}

- (IBAction)searchButtonClicked:(UIButton *)sender {
    
}
@end
