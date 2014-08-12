//
//  SafeToEatViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 3/3/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "SafeToEatViewController.h"
#import "SearchViewController.h"
#import <Reachability/Reachability.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface SafeToEatViewController ()

- (IBAction)searchButtonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;

@end

@implementation SafeToEatViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    FAKIcon *aboutIcon = [FAKIonIcons ios7HelpOutlineIconWithSize:30];
    [aboutIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [self.aboutButton setAttributedTitle:[aboutIcon attributedString]
                                forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location :(");
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchSegue"]) {
        SearchViewController *svc = (SearchViewController *)segue.destinationViewController;
        svc.inSearchMode = [segue.identifier isEqualToString:@"SearchSegue"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)searchButtonClicked:(UIButton *)sender {
    
}
@end
