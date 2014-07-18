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
#import "InspectionsTableViewController.h"

@interface RestaurantTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *restaurantLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yelpRatingImageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *verdictLabel;
@property (weak, nonatomic) IBOutlet UILabel *failedInspectionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *letterGradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *complaintsLbl;
@property (weak, nonatomic) IBOutlet UITableViewCell *verdictCell;
@property (weak, nonatomic) IBOutlet UITableView *inspectionsTable;

@end

@implementation RestaurantTableViewController {
    InspectionListDataSourceDelegate *inspectionsListDataSource;
}


//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataRetrieved)
                                                 name:@"initWithJSONWithIdFinishedLoading"
                                               object:nil];
    
    self.restaurant = [[Restaurant alloc] initWithJSONWithId:self.restaurantId];

    self.restaurantName.text = self.restaurantNameString;
    self.address1Label.text = self.restaurantAddressString;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)dataRetrieved {
    self.restaurantName.text = self.restaurant.name;
    self.address1Label.text = self.restaurant.addressLine1;
    self.address2Label.text = self.restaurant.addressLine2;
    self.failedInspectionsLabel.text = self.restaurant.failedInspectionsString;
    self.letterGradeLabel.text = self.restaurant.eatSafeRating;

    self.verdictLabel.text = self.restaurant.verdictString;
    [self.verdictCell.contentView setBackgroundColor:self.restaurant.ratingColor];

    self.complaintsLbl.text = [NSString stringWithFormat:@"%d", self.restaurant.complaints];

    [self.yelpRatingImageView setImage:self.restaurant.yelpRatingImage];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"BusinessPlaceholder"];
    
    __weak UIImageView *weakImage = self.restaurantLogoImageView;
    
    [self.restaurantLogoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.restaurant.profilePictureURL]
                                        placeholderImage:placeholderImage
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     
                                                     weakImage.image = image;
                                                     [weakImage setNeedsLayout];
                                                 } failure:nil];

    inspectionsListDataSource = [[InspectionListDataSourceDelegate alloc] init];
    inspectionsListDataSource.inspections = self.restaurant.inspectionList;
    [self.inspectionsTable setDataSource:inspectionsListDataSource];
    [self.inspectionsTable reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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

@end
