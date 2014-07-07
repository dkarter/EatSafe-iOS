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

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController
@synthesize searchResults;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
 //   static NSString *CellIdentifier = @"Cell";
 //   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 //
 //   if (!cell) {
 //       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
 //   }
    //set cell type
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *addressLabel =  (UILabel *)[cell.contentView viewWithTag:20];
    UIImageView *restaurantImage = (UIImageView *)[cell.contentView viewWithTag:30];
    UILabel *ratingLabel =  (UILabel *)[cell.contentView viewWithTag:40];
    UIImageView *ratingImage = (UIImageView *)[cell.contentView viewWithTag:50];
    UILabel *distanceLabel =  (UILabel *)[cell.contentView viewWithTag:60];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"your_placeholder"];
    
    Restaurant *currentRestaurant = self.searchResults[indexPath.row];
    


    __weak UIImageView *weakImage = restaurantImage;
    
    [restaurantImage setImageWithURLRequest:[NSURLRequest requestWithURL:currentRestaurant.profilePictureURL]
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       weakImage.image = image;
                                       [weakImage setNeedsLayout];
                                   } failure:nil];


//    NSURL *urlRatingImage = [NSURL URLWithString:self.searchResults[indexPath.row][@"yelp_rating_pic"]];
//    NSURLRequest *requestRatingImage = [NSURLRequest requestWithURL:urlRatingImage];
//    NSLog(@"%@", urlRatingImage);
//    
//    __weak UIImageView *weakImage2 = ratingImage;
//    
//    [ratingImage setImageWithURLRequest:requestRatingImage
//                           placeholderImage:placeholderImage
//                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                        
//                                        weakImage2.image = image;
//                                        [weakImage2 setNeedsLayout];
//                                    } failure:nil];

    titleLabel.text = currentRestaurant.name;
    addressLabel.text = currentRestaurant.addressLine1;
    ratingLabel.text = currentRestaurant.eatSafeRating;
    
    
    //TODO: refactor to property
    distanceLabel.text = [NSString stringWithFormat:@"%f miles", currentRestaurant.distance];
    
    [ratingLabel setBackgroundColor:currentRestaurant.ratingColor];

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.focusSearch) {
        [self.searchBar becomeFirstResponder];
    }
    self.searchResults = [[NSArray alloc] init];
    [self getRestaurantsByLongitude:self.location.coordinate.longitude latitude:self.location.coordinate.latitude];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];

    RestaurantTableViewController *rtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantTableView"];
    rtvc.restaurantId = self.searchResults[indexPath.row][@"id"];
    rtvc.location = self.location;
    
    [self.navigationController pushViewController:rtvc animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    [self getRestaurantsByString:searchBar.text
                       longitude:self.location.coordinate.longitude
                        latitude:self.location.coordinate.latitude];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self getRestaurantsByString:searchBar.text
                       longitude:self.location.coordinate.longitude
                        latitude:self.location.coordinate.latitude];
}

- (void) getRestaurantsByLongitude: (float)longitude latitude:(float) latitude {
    NSString *restaurantURL = @"%@/near?lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           latitude,
                           longitude,
                           500];
    
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

- (void) getRestaurantsByString: (NSString *)searchString longitude: (float)longitude latitude:(float) latitude {
    NSString *restaurantURL = @"%@/instant?query=%@&lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           searchString,
                           latitude,
                           longitude,
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
