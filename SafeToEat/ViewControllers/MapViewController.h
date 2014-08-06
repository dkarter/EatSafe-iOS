//
//  MapViewController.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/27/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationManager.h"
#import "Restaurant.h"
#import "RestaurantAnnotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate,
                                                ESLocationManagerDelegate>
@property NSArray *searchResults;
@end
