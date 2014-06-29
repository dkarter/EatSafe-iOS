//
//  SearchViewController.h
//  SafeToEat
//
//  Created by Dorian Karter on 6/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic) BOOL focusSearch;
@property (strong, nonatomic) CLLocation *location;
@end
