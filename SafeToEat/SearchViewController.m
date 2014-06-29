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

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *gradeColorDictionary;

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
    
    NSURL *urlRestaurantImage = [NSURL URLWithString:self.searchResults[indexPath.row][@"pic"]];
    NSURLRequest *requestRestaurantImage = [NSURLRequest requestWithURL:urlRestaurantImage];

    __weak UIImageView *weakImage = restaurantImage;
    
    [restaurantImage setImageWithURLRequest:requestRestaurantImage
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       weakImage.image = image;
                                       [weakImage setNeedsLayout];
                                   } failure:nil];


    NSURL *urlRatingImage = [NSURL URLWithString:self.searchResults[indexPath.row][@"yelp_rating_pic"]];
    NSURLRequest *requestRatingImage = [NSURLRequest requestWithURL:urlRatingImage];
    NSLog(@"%@", urlRatingImage);
    
    __weak UIImageView *weakImage2 = ratingImage;
    
    [ratingImage setImageWithURLRequest:requestRatingImage
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        
                                        weakImage2.image = image;
                                        [weakImage2 setNeedsLayout];
                                    } failure:nil];

    titleLabel.text = self.searchResults[indexPath.row][@"name"];
    addressLabel.text = self.searchResults[indexPath.row][@"address"];
    ratingLabel.text = self.searchResults[indexPath.row][@"rating"];
    
    distanceLabel.text = [NSString stringWithFormat:@"%@ miles", self.searchResults[indexPath.row][@"dist"]];
    
    [ratingLabel setBackgroundColor:[self.gradeColorDictionary objectForKey:self.searchResults[indexPath.row][@"rating"]]];

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.focusSearch) {
        [self.searchBar becomeFirstResponder];
    }
    self.searchResults = [[NSArray alloc] init];
    float baseColor = 255.0f;
    self.gradeColorDictionary =
        @{@"A": [UIColor colorWithRed:57.0f/baseColor green:181.0f/baseColor blue:74.0f/baseColor alpha:1],
          @"B": [UIColor colorWithRed:171.0f/baseColor green:219.0f/baseColor blue:69.0f/baseColor alpha:1],
          @"C": [UIColor colorWithRed:245.0f/baseColor green:168.0f/baseColor blue:77.0f/baseColor alpha:1],
          @"F": [UIColor colorWithRed:237.0f/baseColor green:28.0f/baseColor blue:36.0f/baseColor alpha:1]};
    [self getRestaurantsByLongitude:self.location.coordinate.longitude latitude:self.location.coordinate.latitude];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"RestaurantPageSegue"]) {
//        //get the details for the specific restaurant and pass to dest view controller
//        RestaurantTableViewController *rtvc = [segue destinationViewController];
//        
//        //rtvc.restaurantData =
//    }
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];

    RestaurantTableViewController *rtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantTableView"];
    rtvc.restaurantNameString = self.searchResults[indexPath.row][@"name"];
    rtvc.restaurantAddressString = self.searchResults[indexPath.row][@"address"];
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
    NSString *restaurantURL = @"http://eatsafe.ngrok.com/near?lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           latitude,
                           longitude,
                           500];
    
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

- (void) getRestaurantsByString: (NSString *)searchString longitude: (float)longitude latitude:(float) latitude {
    NSString *restaurantURL = @"http://eatsafe.ngrok.com/instant?query=%@&lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
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
