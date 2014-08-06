//
//  RestaurantAnnotation.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Restaurant.h"

@interface RestaurantAnnotation : NSObject <MKAnnotation>

- (id)initWithRestaurant:(Restaurant *)restaurant;

@property (strong, nonatomic) Restaurant *restaurant;

//MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;


@end
