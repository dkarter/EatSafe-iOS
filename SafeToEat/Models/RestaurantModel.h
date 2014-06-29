//
//  RestaurantModel.h
//  SafeToEat
//
//  Created by Dorian Karter on 6/28/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantModel : NSObject
//{"count": 11, "score": 71, "dist": 172.04828850874202, "name": "DA LOBSTA", "address": "12 E CEDAR ST "}
@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSDecimal dist;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;

+ (void) getRestaurantsByNameLocation: (NSString *)name address:(NSString *)address;
+ (void) getRestaurantsByNameCurrentLocation: (NSString *)name;
+ (void) getRestaurantsByLocation: (float)longitude latitude:(float) latitude;
@end
