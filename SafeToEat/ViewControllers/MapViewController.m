//
//  MapViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/27/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "MapViewController.h"
#import "RestaurantTableViewController.h"
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
    MKUserLocation *userLocation;
}

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

- (void)didRecieveLocationUpdate:(CLLocation *)location {
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    [self.restaurantMap setRegion:region animated:NO];
    userLocation = [[MKUserLocation alloc] init];
    userLocation.coordinate = location.coordinate;
    userLocation.title = @"Current Location";
    userLocation.subtitle = @"This is where you are";

    [self.restaurantMap addAnnotation:userLocation];
    [locationManager stopUpdatingLocation];
}


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
        
        if ([self.restaurantMap.annotations count] > 300) {
            //still don't want to remove current user location
            NSMutableArray *annotationsToRemove = [self.restaurantMap.annotations mutableCopy];
            [annotationsToRemove removeObject:userLocation];
            [self.restaurantMap removeAnnotations:annotationsToRemove];
        } else {
            [self removeAnnotations];
        }

        

        
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
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(annotationCalloutTapped:) forControlEvents:UIControlEventTouchUpInside];
        annotView.rightCalloutAccessoryView = rightButton;
        
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

- (void)annotationCalloutTapped:(UIButton *)sender {
    RestaurantAnnotation *annot = self.restaurantMap.selectedAnnotations[0];
    RestaurantTableViewController *rtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantTableView"];
    rtvc.restaurant = annot.restaurant;
    [self.navigationController pushViewController:rtvc animated:YES];
}

- (void)removeAnnotations {
    NSArray *annotations = self.restaurantMap.annotations;
    for (id<MKAnnotation> annot in annotations) {
        //check if not userlocation
        if ([annot isKindOfClass:[RestaurantAnnotation class]]) {
            RestaurantAnnotation *restAnnot = annot;
            //check if still in view
            if(!MKMapRectContainsPoint(self.restaurantMap.visibleMapRect, MKMapPointForCoordinate(restAnnot.coordinate)))
            {
                //TODO: maybe optimize by passing array instead of single every time
                //may save the removal process some time cause it doesn't have to refresh the view repeatedly but only once
                [self.restaurantMap removeAnnotation:annot];
            }
        }
    }
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
