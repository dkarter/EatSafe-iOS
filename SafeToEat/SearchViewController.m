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

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) id<UIApplicationDelegate> appDelegate;
@end

@implementation SearchViewController

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
    } else {
        self.locationManager = [[LocationManager alloc] initWithDelegate:self];
        [self.locationManager startUpdatingLocation];

    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self
                       action:@selector(handleLocationBasedRefresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [self.searchResultsTableView addSubview:refreshControl];
    UIImage *logo = [UIImage imageNamed:@"LogoNavBar"];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logo];
    
    
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
    UIImageView *ratingImage = (UIImageView *)[cell.contentView viewWithTag:50];
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
        
        [ratingImage setImage:currentRestaurant.yelpRatingImage];
        
        titleLabel.text = currentRestaurant.name;
        addressLabel.text = currentRestaurant.addressLine1;
        distanceLabel.text = currentRestaurant.distanceString;
        ratingLabel.text = currentRestaurant.eatSafeRating;
        
        [ratingLabel setBackgroundColor:currentRestaurant.ratingColor];

    }

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}



- (void)handleLocationBasedRefresh:(UIRefreshControl *)sender {
    [self.locationManager startUpdatingLocation];
    [sender endRefreshing];
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
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
}





- (void)didRecieveLocationUpdate:(CLLocation *)location {
    if ([self.searchBar.text isEqualToString:@""]) {
        [self getRestaurantsByCoordinate:location.coordinate];
    } else {
        [self searchRestaurantsByString:self.searchBar.text coordinate:location.coordinate];
    }

    [self.locationManager stopUpdatingLocation];
}

#pragma mark - APICalls

- (void) getRestaurantsByCoordinate: (CLLocationCoordinate2D)coordinate {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";


    NSString *restaurantURL = @"%@/near?lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           coordinate.latitude,
                           coordinate.longitude,
                           500];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url: %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSONArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *JSON in JSONArray) {
            Restaurant *tempRestaurant = [[Restaurant alloc] initWithJSONObject:JSON];
            [tempArray addObject:tempRestaurant];
        }
        
        searchResults = [NSArray arrayWithArray:tempArray];
        
        [self.searchResultsTableView reloadData];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [hud hide:YES];
    }];

    [operation start];
    
}


- (void) searchRestaurantsByString: (NSString *)searchString
                        coordinate: (CLLocationCoordinate2D)coordinate {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Searching";
    NSString *restaurantURL = @"%@/instant?query=%@&lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           searchString,
                           coordinate.latitude,
                           coordinate.longitude,
                           500];
    NSLog(@"%@", urlString);
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSONArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *JSON in JSONArray) {
            Restaurant *tempRestaurant = [[Restaurant alloc] initWithJSONObject:JSON];
            [tempArray addObject:tempRestaurant];
        }

        self.searchResults = [NSArray arrayWithArray: tempArray];
        [self.searchResultsTableView reloadData];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [hud hide:YES];
    }];
    
    [operation start];
}


@end
