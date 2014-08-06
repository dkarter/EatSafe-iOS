//
//  RestaurantAnnotation.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "RestaurantAnnotation.h"

@implementation RestaurantAnnotation

- (id)initWithRestaurant:(Restaurant *)restaurant {
    self = [super init];
    
    if (self) {
        self.restaurant = restaurant;
    }
    
    return self;
}


- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.restaurant.latitude doubleValue],
                                      [self.restaurant.longitude doubleValue]);
}

- (NSString *)title {
    return self.restaurant.name;
}

- (NSString *)subtitle{
    return self.restaurant.addressLine1;
}
@end
