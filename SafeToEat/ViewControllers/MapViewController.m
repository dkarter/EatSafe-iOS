//
//  MapViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/27/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "MapViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>


@interface MapViewController ()
@property (strong, nonatomic) IBOutlet MKMapView *restaurantMap;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
- (IBAction)currentLocationButtonTapped:(UIButton *)sender;


@end

@implementation MapViewController {
    LocationManager *locationManager;
    UIImage *mapMarkerImageRed;
    UIImage *mapMarkerImageGreen;
}
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add logo to navigation controller top bar
    UIImageView *navigationImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 106, 30)];
    navigationImage.image=[UIImage imageNamed:@"LogoNavBar"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 106, 30)];
    [workaroundImageView addSubview:navigationImage];
    self.navigationItem.titleView=workaroundImageView;
    
    FAKIcon *currentLocationIcon = [FAKIonIcons pinpointIconWithSize:30];
    [self.currentLocationButton setAttributedTitle:[currentLocationIcon attributedString]
                                          forState:UIControlStateNormal];
    
    locationManager = [[LocationManager alloc] initWithDelegate:self];
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRecieveLocationUpdate:(CLLocation *)location {
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    [self.restaurantMap setRegion:region animated:NO];
    MKUserLocation *annot = [[MKUserLocation alloc] init];
    annot.coordinate = location.coordinate;
    annot.title = @"Current Location";
    annot.subtitle = @"This is where you are";

    [self.restaurantMap addAnnotation:annot];
    [locationManager stopUpdatingLocation];
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


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [Restaurant getRestaurantsByCoordinate:mapView.region.center
                                  distance:[self getRadius]
                                       max:100
                                completion:^(NSArray *restaurants) {
                                    [self didRecieveRestaurantList:restaurants];
                                }];
}

-(void)didRecieveRestaurantList:(NSArray *)restaurants {

    
    if ([restaurants count] > 0) {
        self.searchResults = restaurants;
        
        [self.restaurantMap removeAnnotations:self.restaurantMap.annotations];
        
        for (Restaurant *rest in self.searchResults) {
            RestaurantAnnotation *annot = [[RestaurantAnnotation alloc] initWithRestaurant:rest];
            [self.restaurantMap addAnnotation:annot];
        }

    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[RestaurantAnnotation class]]) {
            static NSString *identifier = @"identifier";
        MKAnnotationView *annotView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
        if (annotView == nil) {
            annotView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                     reuseIdentifier:identifier];
        }
    
        annotView.enabled = YES;
        annotView.annotation = annotation;
        annotView.canShowCallout = YES;
        Restaurant *restaurant = ((RestaurantAnnotation *)annotation).restaurant;
        if (restaurant.noRecentFails) {
            annotView.image = [UIImage imageNamed:@"PassAnnotation"];
        } else {
            annotView.image = [UIImage imageNamed:@"FailAnnotation"];
        }

        
        return annotView;
    }
    
    return nil;
}


- (int)getRadius
{
    CLLocationCoordinate2D centerCoor = [self.restaurantMap centerCoordinate];
    // init center location from center coordinate
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    
    CLLocationCoordinate2D topCenterCoor = [self.restaurantMap convertPoint:CGPointMake(self.restaurantMap.frame.size.width / 2.0f, 0) toCoordinateFromView:self.restaurantMap];
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterCoor.latitude longitude:topCenterCoor.longitude];
    

    NSNumber *radius = [NSNumber numberWithDouble:[centerLocation distanceFromLocation:topCenterLocation] / 0.621371192];

    return [radius intValue];
}

- (IBAction)currentLocationButtonTapped:(UIButton *)sender {
    [locationManager startUpdatingLocation];
}
@end
