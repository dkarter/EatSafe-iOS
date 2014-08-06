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
#import <MBProgressHUD/MBProgressHUD.h>
#import "ViewControllers/InspectionDetailsTableViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

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
@property (weak, nonatomic) IBOutlet UILabel *yelpReviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@end

@implementation RestaurantTableViewController {
    InspectionListDataSourceDelegate *inspectionsListDataSource;
    MBProgressHUD *hud;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    
    //set right icon
    FAKIcon *moreIcon = [FAKIonIcons ios7MoreOutlineIconWithSize:30];
    [moreIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    UIButton *actionsButtonWithIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionsButtonWithIcon setFrame:CGRectMake(0, 0, 30, 30)];
    [actionsButtonWithIcon setAttributedTitle:[moreIcon attributedString] forState:UIControlStateNormal];
    [actionsButtonWithIcon addTarget:self action:@selector(actionsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:actionsButtonWithIcon];

    self.navigationItem.rightBarButtonItem = moreButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataRetrieved)
                                                 name:@"initRestaurantWithJSONWithIdFinishedLoading"
                                               object:nil];
    
    [self bindData];
    
    self.restaurant = [[Restaurant alloc] initWithJSONWithId:self.restaurant.restaurantId];

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bindData {
    @try {
        self.restaurantName.text = self.restaurant.name;
        self.address1Label.text = self.restaurant.addressLine1;
        self.address2Label.text = self.restaurant.addressLine2;
        self.phoneLabel.text = self.restaurant.formattedPhoneNumber;
        self.failedInspectionsLabel.text = self.restaurant.failedInspectionsString;
        self.letterGradeLabel.text = self.restaurant.eatSafeRating;
        
        self.verdictLabel.text = self.restaurant.verdictString;
        [self.verdictCell.contentView setBackgroundColor:self.restaurant.ratingColor];
        
        self.complaintsLbl.text = [NSString stringWithFormat:@"%d", [self.restaurant.complaints intValue]];
        @try {
            [self.yelpRatingImageView setImage:self.restaurant.yelpRatingImage];
            self.yelpReviewCountLabel.text = [NSString stringWithFormat:@"(%d)", [self.restaurant.yelpReviewCount intValue]];
        }
        @catch (NSException *exception) {
            
        }
        
        UIImage *placeholderImage = [UIImage imageNamed:@"BusinessPlaceholder"];
        
        __weak UIImageView *weakImage = self.restaurantLogoImageView;
        
        [self.restaurantLogoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.restaurant.profilePictureURL]
                                            placeholderImage:placeholderImage
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                         
                                                         weakImage.image = image;
                                                         [weakImage setNeedsLayout];
                                                     } failure:nil];

    }
    @catch (NSException *exception) {

    }
}



- (void)dataRetrieved {
    
    [self bindData];
    //individual inspections table
    inspectionsListDataSource = [[InspectionListDataSourceDelegate alloc] init];
    inspectionsListDataSource.inspections = self.restaurant.inspectionList;
    [self.inspectionsTable setDataSource:inspectionsListDataSource];
    [self.inspectionsTable reloadData];
    
    [hud hide:YES];
}

- (BOOL)isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
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



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"InspectionDetailSegue"]) {
        InspectionDetailsTableViewController *dest = segue.destinationViewController;
        HealthInspection *selectedInspection = self.restaurant.inspectionList[[self.inspectionsTable indexPathForSelectedRow].row];
        dest.inspectionData = selectedInspection;
    }
}


- (IBAction)actionsButtonTapped {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    //move button titles to constants
    if ([self isYelpInstalled]) {
        [buttons addObject:@"Visit on Yelp"];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *button in buttons) {
        [actionSheet addButtonWithTitle:button];
    }
    //add cancel here so that it's separated and on the bottom

    //if no buttons have been added don't show - maybe even hide icon
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}
#pragma mark - UISheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //move button titles to constants
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Visit on Yelp"]) {
        NSString *urlString = [NSString stringWithFormat:@"yelp:///biz/%@", self.restaurant.restaurantId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}
@end
