//
//  RestaurantTableViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 6/29/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "RestaurantTableViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface RestaurantTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *restaurantLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yelpRatingImageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *verdictLabel;
@property (weak, nonatomic) IBOutlet UILabel *failedInspectionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestInspectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;

@end

@implementation RestaurantTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getRestaurantsByString:[NSString stringWithFormat:@"%@ %@",
                                  self.restaurantNameString,
                                  self.restaurantAddressString]
                       longitude:self.location.coordinate.longitude
                        latitude:self.location.coordinate.latitude];
    self.restaurantName.text = self.restaurantNameString;
        self.address1Label.text = self.restaurantAddressString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (void) getRestaurantsByString: (NSString *)searchString longitude: (float)longitude latitude:(float) latitude {
    NSString *restaurantURL = @"http://eatsafe.ngrok.com/place?query=%@&lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           searchString,
                           latitude,
                           longitude,
                           500];
    NSLog(@"YEAAA fucker%@", urlString);
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.restaurantData = responseObject;
        self.address2Label.text = responseObject[@"address2"];
        
        
        UIImage *placeholderImage = [UIImage imageNamed:@"your_placeholder"];
        
        NSURL *urlRestaurantImage = [NSURL URLWithString:responseObject[@"pic"]];
        NSURLRequest *requestRestaurantImage = [NSURLRequest requestWithURL:urlRestaurantImage];
        
        __weak UIImageView *weakImage = self.restaurantLogoImageView;
        
        [self.restaurantLogoImageView setImageWithURLRequest:requestRestaurantImage
                               placeholderImage:placeholderImage
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            
                                            weakImage.image = image;
                                            [weakImage setNeedsLayout];
                                        } failure:nil];
        
        
        NSURL *urlRatingImage = [NSURL URLWithString:responseObject[@"yelp_rating_pic"]];
        NSURLRequest *requestRatingImage = [NSURLRequest requestWithURL:urlRatingImage];
        NSLog(@"%@", urlRatingImage);
        
        __weak UIImageView *weakImage2 = self.yelpRatingImageView;
        
        [self.yelpRatingImageView setImageWithURLRequest:requestRatingImage
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        
                                        weakImage2.image = image;
                                        [weakImage2 setNeedsLayout];
                                    } failure:nil];

        
        
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










//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
