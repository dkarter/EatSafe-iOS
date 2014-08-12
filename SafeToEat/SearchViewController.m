//
//  SearchViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 6/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RestaurantTableViewController.h"
#import "Restaurant.h"
#import "FontAwesomeKit/FontAwesomeKit.h"
#import "StringHelpers.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) id<UIApplicationDelegate> appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@end

@implementation SearchViewController {
    MBProgressHUD *hud;
    FAKIcon *passIcon;
    FAKIcon *failIcon;

}

bool useLocation = YES;
@synthesize searchResults;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.searchResults = [[NSArray alloc] init];
    
    //setup search bar
    if (self.inSearchMode) {
        [self.searchBar becomeFirstResponder];
    }
    
    
    self.locationManager = [[LocationManager alloc] initWithDelegate:self];
    [self.locationManager startUpdatingLocation];

    passIcon = [FAKFontAwesome checkIconWithSize:40];
    failIcon = [FAKFontAwesome timesIconWithSize:40];

    
//    FAKIcon *mapIcon = [FAKIonIcons mapIconWithSize:25];
    FAKIcon *mapIcon = [FAKIonIcons ios7LocationOutlineIconWithSize:25];
    self.mapButton.title = @"";
    self.mapButton.image = [mapIcon imageWithSize:CGSizeMake(25, 25)];

    // make cancel button on search appear white
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
          setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
          forState:UIControlStateNormal];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self
                       action:@selector(handleLocationBasedRefresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [self.searchResultsTableView addSubview:refreshControl];

    //add logo to navigation controller top bar
    UIImageView *navigationImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, -5, 106, 30)];
    navigationImage.image=[UIImage imageNamed:@"LogoNavBar"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 106, 30)];
    [workaroundImageView addSubview:navigationImage];
    self.navigationItem.titleView=workaroundImageView;
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    //get custom cell controls using tags
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *addressLabel =  (UILabel *)[cell.contentView viewWithTag:20];
    UIImageView *restaurantImage = (UIImageView *)[cell.contentView viewWithTag:30];
    UILabel *ratingLabel =  (UILabel *)[cell.contentView viewWithTag:40];
    UILabel *distanceLabel =  (UILabel *)[cell.contentView viewWithTag:60];
    

    
    Restaurant *currentRestaurant = self.searchResults[indexPath.row];
    if (currentRestaurant != nil || ![currentRestaurant isEqual:[NSNull null]]) {
        UIImage *placeholderImage = [UIImage imageNamed:@"BusinessPlaceholder"];
        
        if ([currentRestaurant.profilePictureURL isEqual:nil]) {
            [restaurantImage setImage:placeholderImage];
        } else {
            __weak UIImageView *weakImage = restaurantImage;
            
            [restaurantImage setImageWithURLRequest:[NSURLRequest requestWithURL:currentRestaurant.profilePictureURL]
                                   placeholderImage:placeholderImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                weakImage.image = image;
                                                [weakImage setNeedsLayout];
                                            }
                                            failure:nil];
        }
        
        titleLabel.text = currentRestaurant.name;
        addressLabel.text = currentRestaurant.addressLine1;
        distanceLabel.text = currentRestaurant.distanceString;
        
        if (currentRestaurant.noRecentFails) {
            ratingLabel.attributedText = [passIcon attributedString];
        } else {
            ratingLabel.attributedText = [failIcon attributedString];
        }

        
        [ratingLabel setTextColor:currentRestaurant.ratingColor];

    }

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}



- (void)handleLocationBasedRefresh:(UIRefreshControl *)sender {
    [self.locationManager startUpdatingLocation];
    if (sender != nil) {
        [sender endRefreshing];
    }

}


#pragma mark - TableViewActions


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];

    RestaurantTableViewController *rtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantTableView"];
    Restaurant *selectedRestaurant = self.searchResults[indexPath.row];
    rtvc.restaurant = selectedRestaurant;

    
    [self.navigationController pushViewController:rtvc animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.locationManager startUpdatingLocation];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //add auto complete code here with just suggestion text - otherwise will overload the server
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];

    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([StringHelpers isEmpty:searchBar.text]) {
        [searchBar setShowsCancelButton:NO animated:YES];
    }
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar canResignFirstResponder]) {
        [searchBar resignFirstResponder];
    }

    [searchBar setText:@""];
    [self handleLocationBasedRefresh:nil];
}

-(void)didRecieveRestaurantList:(NSArray *)restaurants {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hud != nil) {
            [hud hide:YES];
            hud = nil;
        }
        
        self.searchResults = restaurants;
        [self.searchResultsTableView reloadData];
    });

}

- (void)didRecieveLocationUpdate:(CLLocation *)location {
    BOOL isAroundMeMode = [self.searchBar.text isEqualToString:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hud == nil) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = isAroundMeMode ? @"Loading" : @"Searching";
        }
    });
    
    if (isAroundMeMode) {
        [Restaurant getRestaurantsByCoordinate:location.coordinate
                                    completion:^(NSArray *restaurants) {
                                        [self didRecieveRestaurantList:restaurants];
                                    }];

    } else {
        [Restaurant searchRestaurantsByString:self.searchBar.text
                                   coordinate:location.coordinate
                                   completion:^(NSArray *restaurants) {
                                        [self didRecieveRestaurantList:restaurants];
                                   }];
    }
    
    [self.locationManager stopUpdatingLocation];
}

@end
