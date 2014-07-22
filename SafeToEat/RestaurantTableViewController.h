//
//  RestaurantTableViewController.h
//  SafeToEat
//
//  Created by Dorian Karter on 6/29/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Restaurant.h"
#import "HealthInspection.h"
#import "InspectionListDataSourceDelegate.h"

@interface RestaurantTableViewController : UITableViewController
@property (strong, nonatomic) Restaurant *restaurant;
@property (strong, nonatomic) NSString *restaurantNameString;
@property (strong, nonatomic) NSString *restaurantAddressString;
@property (strong, nonatomic) CLLocation *location;

@end
