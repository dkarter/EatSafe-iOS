//
//  Restaurant.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/6/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "Restaurant.h"
#import "AFNetworking.h"
#import "Models/HealthInspection.h"

@implementation Restaurant


- (id)init {
    self = [super init];
    return self;
}

- (id)initWithJSONWithId:(NSString *)restaurantId {
    self = [super init];
    if (self) {
        NSString *restaurantURL = @"%@/place?id=%@";
        
        NSString *urlString = [NSString stringWithFormat:restaurantURL,
                               kESBaseURL, restaurantId];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {

            [self fillFromJSON:JSON];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"initWithJSONWithIdFinishedLoading"
                              object:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Cannot retrieve restaurant: %@", error.localizedDescription);
        }];
        
        [operation start];
    }
    
    return self;
}


- (id)initWithJSONObject:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        [self fillFromJSON:JSON];
    }
    return self;
}

- (void)fillFromJSON:(NSDictionary *)JSON {
    self.name               = JSON[@"name"];
    self.restaurantId       = JSON[@"id"];
    self.addressLine1       = JSON[@"address"];
    self.addressLine2       = JSON[@"address2"];
    self.eatSafeRating      = JSON[@"rating"];
    self.isNew              = [JSON[@"new"] boolValue];
    self.yelpRating         = [[JSON[@"yelp_rating"] class] isSubclassOfClass:[NSNull class]] ? 0.0f : [JSON[@"yelp_rating"] floatValue];
    self.distance           = [JSON[@"dist"] floatValue];
    self.failures           = [JSON[@"fails"] intValue];
    self.complaints         = [JSON[@"complaints"] intValue];
    self.inspectionCount    = [JSON[@"count"] intValue];
    self.longitude          = [JSON[@"long"] floatValue];
    self.latitude           = [JSON[@"lat"] floatValue];
    
    //load individual inspections into array of healthinspection objects
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSDictionary *inspectionsJSON in JSON[@"inspections"]) {
        HealthInspection *tempInspection = [[HealthInspection alloc] initWithJSONObject:inspectionsJSON];
        [tempArray addObject:tempInspection];
    }
    
    self.inspectionList = [NSArray arrayWithArray:tempArray];
    
    
    
    if (![JSON[@"pic"] isEqualToString:@""]) {
        self.profilePictureURL  = [NSURL URLWithString:JSON[@"pic"]];
    } else {
        self.profilePictureURL = nil;
    }

}

- (UIColor *)ratingColor {
    float baseColor = 255.0f;
    NSDictionary *gradeColorDictionary = @{@"A": [UIColor colorWithRed:57.0f/baseColor green:181.0f/baseColor blue:74.0f/baseColor alpha:1],
    @"B": [UIColor colorWithRed:171.0f/baseColor green:219.0f/baseColor blue:69.0f/baseColor alpha:1],
    @"C": [UIColor colorWithRed:245.0f/baseColor green:168.0f/baseColor blue:77.0f/baseColor alpha:1],
    @"F": [UIColor colorWithRed:237.0f/baseColor green:28.0f/baseColor blue:36.0f/baseColor alpha:1]};
    return gradeColorDictionary[self.eatSafeRating];
}

- (NSString *)failedInspectionsString {
    return [NSString stringWithFormat:@"%d/%d", self.failures, self.inspectionCount];
}

- (NSString *)verdictString {
    if ([self.eatSafeRating isEqual: @"A"]) {
        return @"Safe";
    } else if ([self.eatSafeRating isEqual: @"B"]) {
        return @"Fairly Safe";
    } else if ([self.eatSafeRating isEqual: @"C"]) {
        return @"Questionable";
    } else if([self.eatSafeRating isEqual: @"F"]) {
        return @"Avoid";
    }
    return @"Error";
}

- (UIImage *)yelpRatingImage {
    //return gray boxes with no rating
    UIImage *result = [UIImage imageNamed:[NSString stringWithFormat:@"yelp_%f", self.yelpRating]];
    return result;
}

- (NSString *)distanceString {
    return [NSString stringWithFormat:@"%0.1f miles", self.distance];
}

@end
