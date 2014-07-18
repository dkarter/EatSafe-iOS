//
//  InspectionListDataSourceDelegate.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/16/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthInspection.h"

@interface InspectionListDataSourceDelegate : NSObject <UITableViewDataSource,
                                                        UITableViewDelegate>
@property (strong, nonatomic) NSArray *inspections;

@end
