//
//  Restaurant.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/6/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (strong, nonatomic) NSString *restaurantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *addressLine1;
@property (strong, nonatomic) NSString *addressLine2;
@property (strong, nonatomic) NSString *eatSafeRating;
@property (strong, nonatomic, readonly) NSString *failedInspectionsString;
@property (strong, nonatomic, readonly) NSString *verdictString;
@property (strong, nonatomic, readonly) UIColor *ratingColor;
@property (nonatomic) BOOL isNew;
@property (nonatomic) float yelpRating;
@property (nonatomic) int failures;
@property (nonatomic) int complaints;
@property (nonatomic) int inspectionCount;
@property (nonatomic) float distance;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (strong, nonatomic) NSURL *profilePictureURL;
@property (strong, nonatomic) NSURL *yelpURL;

//initializers
- (id)initWithJSONWithId:(NSString *)restaurantId;

@end
