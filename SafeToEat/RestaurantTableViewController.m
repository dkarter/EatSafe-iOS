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
#import <MapKit/MapKit.h>

@interface RestaurantTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *restaurantLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yelpRatingImageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *inspectionsTable;
@property (weak, nonatomic) IBOutlet UILabel *yelpReviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@end

@implementation RestaurantTableViewController {
    InspectionListDataSourceDelegate *inspectionsListDataSource;
    MBProgressHUD *hud;
    Restaurant *restaurantFull;
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
    
    restaurantFull = [[Restaurant alloc] initWithJSONWithId:self.restaurant.restaurantId];
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
        self.distanceLabel.text = self.restaurant.distance == nil ? self.distanceLabel.text : self.restaurant.distanceString;
        self.phoneLabel.text = restaurantFull.formattedPhoneNumber;
        
        @try {
            [self.yelpRatingImageView setImage:self.restaurant.yelpRatingImage];
            self.yelpReviewCountLabel.text = [NSString stringWithFormat:@"(%d)", [restaurantFull.yelpReviewCount intValue]];
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
        NSLog(@"%@", exception);
    }
}



- (void)dataRetrieved {
    
    [self bindData];
    //individual inspections table
    inspectionsListDataSource = [[InspectionListDataSourceDelegate alloc] init];
    inspectionsListDataSource.inspections = restaurantFull.inspectionList;
    [self.inspectionsTable setDataSource:inspectionsListDataSource];
    [self.inspectionsTable reloadData];
    
    [hud hide:YES];
}

- (BOOL)isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
}

- (BOOL)isGoogleMapsInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
}

- (void)openInAppleMaps {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.restaurant.coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.restaurant.name];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    }
}

- (void)openUrl:(NSString *)urlString {
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"InspectionDetailSegue"]) {
        InspectionDetailsTableViewController *dest = segue.destinationViewController;
        HealthInspection *selectedInspection = restaurantFull.inspectionList[[self.inspectionsTable indexPathForSelectedRow].row];
        dest.inspectionData = selectedInspection;
    }
}


- (IBAction)actionsButtonTapped {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    //move button titles to constants
    if ([self isYelpInstalled]) {
        [buttons addObject:@"Visit on Yelp"];
    } else {
        [buttons addObject:@"Yelp app is not installed"];
    }
    
    if ([self isGoogleMapsInstalled]) {
        [buttons addObject:@"Find on Google Maps"];
    }
    
    [buttons addObject:@"Find on Apple Maps"];

    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];

    [buttons addObject:@"Cancel"];
    
    for (NSString *button in buttons) {
        [actionSheet addButtonWithTitle:button];
    }
    

    
    [actionSheet setCancelButtonIndex:[buttons count] - 1];
    //add cancel here so that it's separated and on the bottom

    //if no buttons have been added don't show - maybe even hide icon
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //TODO: move button titles to constants
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Visit on Yelp"]) {
        
        NSString *urlString = [NSString stringWithFormat:@"yelp:///search?terms=%@&location=%@",
                               self.restaurant.restaurantId, self.restaurant.addressLine1];
        [self openUrl:urlString];
    } else if ([buttonTitle isEqualToString:@"Find on Apple Maps"]) {
        [self openInAppleMaps];
    } else if ([buttonTitle isEqualToString:@"Find on Google Maps"]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?q=%@ %@&center=%f,%f&zoom=14",
                               self.restaurant.name,
                               self.restaurant.addressLine1,
                               [self.restaurant.latitude floatValue],
                               [self.restaurant.longitude floatValue]];
        
        [self openUrl:urlString];

        
    }
}
@end
