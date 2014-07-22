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
@property (strong, nonatomic) NSURL *profilePictureURL;
@property (strong, nonatomic) NSURL *yelpURL;
@property (strong, nonatomic) NSArray *inspectionList;
@property (nonatomic) BOOL isNew;
@property (strong, nonatomic) NSNumber *yelpRating;
@property (strong, nonatomic) NSNumber *failures;
@property (strong, nonatomic) NSNumber *complaints;
@property (strong, nonatomic) NSNumber *inspectionCount;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *yelpReviewCount;
@property (strong, nonatomic) NSString *phone;

//readonly getters
@property (strong, nonatomic, readonly) NSString *failedInspectionsString;
@property (strong, nonatomic, readonly) NSString *verdictString;
@property (strong, nonatomic, readonly) UIColor  *ratingColor;
@property (strong, nonatomic, readonly) UIImage  *yelpRatingImage;
@property (strong, nonatomic, readonly) NSString *distanceString;

//initializers
- (id)initWithJSONWithId:(NSString *)restaurantId;
- (id)initWithJSONObject:(NSDictionary *)JSON;

@end
