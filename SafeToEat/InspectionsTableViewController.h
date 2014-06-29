//
//  InspectionsTableViewController.h
//  SafeToEat
//
//  Created by Dorian Karter on 6/29/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InspectionsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *inspectionData;
@end
