//
//  SearchViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 6/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "SearchViewController.h"
#import "Models/RestaurantModel.h"
#import "UIImageView+AFNetworking.h"

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *gradeColorDictionary;

@end

@implementation SearchViewController
@synthesize searchResults;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *addressLabel =  (UILabel *)[cell.contentView viewWithTag:20];
    UIImageView *restaurantImage = (UIImageView *)[cell.contentView viewWithTag:30];
    UILabel *ratingLabel =  (UILabel *)[cell.contentView viewWithTag:40];
    
    NSURL *url = [NSURL URLWithString:self.searchResults[indexPath.row][@"pic"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"your_placeholder"];
    
    __weak UITableViewCell *weakCell = cell;
    
    [restaurantImage setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       weakCell.imageView.image = image;
                                       [weakCell setNeedsLayout];
                                       
                                   } failure:nil];

    titleLabel.text = self.searchResults[indexPath.row][@"name"];
    addressLabel.text = self.searchResults[indexPath.row][@"address"];
    ratingLabel.text = self.searchResults[indexPath.row][@"rating"];
    //NSLog(@"%@",[self.gradeColorDictionary objectForKey:self.searchResults[indexPath.row][@"rating"]]);
    //[ratingLabel setBackgroundColor:[UIColor colorWithRed:237 green:28 blue:36 alpha:1]];//[self.gradeColorDictionary objectForKey:self.searchResults[indexPath.row][@"rating"]]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchResults = [[NSArray alloc] init];
    self.gradeColorDictionary =
        @{@"A": [UIColor colorWithRed:57 green:181 blue:74 alpha:1],
          @"B": [UIColor colorWithRed:255 green:232 blue:80 alpha:1],
          @"C": [UIColor colorWithRed:245 green:168 blue:77 alpha:1],
          @"F": [UIColor colorWithRed:237 green:28 blue:36 alpha:1]};
    [self getRestaurantsByLongitude:-87.625916 latitude:41.903196];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    //do search here
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


@end
