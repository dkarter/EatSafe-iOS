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

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locationButton;
- (IBAction)locationButtonTapped:(UIBarButtonItem *)sender;
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
    
    
    //setup loaction button
    FAKFontAwesome *locationIcon = [FAKFontAwesome locationArrowIconWithSize:15];
    self.locationButton.title = @" ";
    [self.locationButton setImage:[locationIcon imageWithSize:CGSizeMake(15,15)]];
    [self.locationButton setTintColor:[UIColor darkGrayColor]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
     forState:UIControlStateNormal];
    
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
    rtvc.restaurantId = selectedRestaurant.restaurantId;

    
    [self.navigationController pushViewController:rtvc animated:YES];
}




- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    [self searchRestaurantsByString:searchBar.text
                         coordinate:self.locationManager.lastLocation.coordinate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self searchRestaurantsByString:searchBar.text
                         coordinate:self.locationManager.lastLocation.coordinate];
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




- (IBAction)locationButtonTapped:(UIBarButtonItem *)sender {
    if (useLocation) {
        [self.locationButton setTintColor:[UIColor whiteColor]];
        [self.locationManager startUpdatingLocation];
        useLocation = NO;
    } else {
        [self.locationButton setTintColor:[UIColor darkGrayColor]];
        useLocation = YES;
    }

}

- (void)didRecieveLocationUpdate:(CLLocation *)location {
    [self getRestaurantsByCoordinate:location.coordinate];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - APICalls

- (void) getRestaurantsByCoordinate: (CLLocationCoordinate2D)coordinate {
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
    
}


- (void) searchRestaurantsByString: (NSString *)searchString
                        coordinate: (CLLocationCoordinate2D)coordinate {
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
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.searchResults = [NSArray arrayWithArray: responseObject];
        [self.searchResultsTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}


@end
