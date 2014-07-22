//
//  InspectionDetailsTableViewController.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/18/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HealthInspection.h"

@interface InspectionDetailsTableViewController : UITableViewController

@property (strong, nonatomic) HealthInspection *inspectionData;

@end
