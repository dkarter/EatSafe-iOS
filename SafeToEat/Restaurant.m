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

+ (void) getRestaurantsByCoordinate: (CLLocationCoordinate2D)coordinate
                         completion:(RetaurantListCompletionBlock)completion {
    
    return [Restaurant getRestaurantsByCoordinate:coordinate distance:500 max:30 completion:completion];

}

+ (void) getRestaurantsByCoordinate: (CLLocationCoordinate2D)coordinate
                           distance:(int)distance
                                max:(int)max
                         completion:(RetaurantListCompletionBlock)completion {
    NSString *restaurantURL = @"%@/near?lat=%f&long=%f&radius=%d&max=%d";
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           coordinate.latitude,
                           coordinate.longitude,
                           distance,
                           max];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSONArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *JSON in JSONArray) {
            Restaurant *tempRestaurant = [[Restaurant alloc] initWithJSONObject:JSON];
            [tempArray addObject:tempRestaurant];
        }
        
        completion([NSArray arrayWithArray:tempArray]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        completion(@[]);
    }];
    
    [operation start];

}


+ (void) searchRestaurantsByString: (NSString *)searchString
                        coordinate: (CLLocationCoordinate2D)coordinate
                        completion:(RetaurantListCompletionBlock)completion {
    NSString *restaurantURL = @"%@/instant?query=%@&lat=%f&long=%f&d=%d";
    
    NSString *urlString = [NSString stringWithFormat:restaurantURL,
                           kESBaseURL,
                           searchString,
                           coordinate.latitude,
                           coordinate.longitude,
                           500];
    NSLog(@"%@", urlString);
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSONArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *JSON in JSONArray) {
            Restaurant *tempRestaurant = [[Restaurant alloc] initWithJSONObject:JSON];
            [tempArray addObject:tempRestaurant];
        }
        
        completion([NSArray arrayWithArray:tempArray]);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error cannot access server at this time."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        completion(@[]);
    }];
    
    [operation start];
}



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
                postNotificationName:@"initRestaurantWithJSONWithIdFinishedLoading"
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
    if (JSON && [JSON isKindOfClass:[NSDictionary class]] && [JSON count] > 0) {
        self.name               = JSON[@"name"];
        self.longitude          = JSON[@"long"];
        self.latitude           = JSON[@"lat"];
        self.restaurantId       = JSON[@"id"];
        self.addressLine1       = JSON[@"address"];
        //self.addressLine2       = JSON[@"address2"];
        self.eatSafeRating      = JSON[@"rating"];
        self.isNew              = [JSON[@"new"] boolValue]; // not really using this one
        self.noRecentFails      = [JSON[@"no_recent_fails"] boolValue];
        self.yelpRating         = JSON[@"yelp_rating"];
        self.distance           = JSON[@"dist"];
        self.failures           = JSON[@"fails"];
        self.complaints         = JSON[@"complaints"];
        self.inspectionCount    = JSON[@"count"];
        self.phone              = [JSON[@"phone"] isKindOfClass:[NSNull class]] ? @"" : [JSON[@"phone"] stringValue];
        self.yelpReviewCount    = JSON[@"yelp_review_count"];
        
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
}

- (UIColor *)ratingColor {
    float baseColor = 255.0f;
    UIColor *passColor = [UIColor colorWithRed:57.0f/baseColor green:181.0f/baseColor blue:74.0f/baseColor alpha:1];
    UIColor *failColor = [UIColor colorWithRed:237.0f/baseColor green:28.0f/baseColor blue:36.0f/baseColor alpha:1];
    return self.noRecentFails ? passColor : failColor;
}

- (NSString *)failedInspectionsString {
    return [NSString stringWithFormat:@"%d/%d", [self.failures intValue], [self.inspectionCount intValue]];
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
    UIImage *result = [UIImage imageNamed:[NSString stringWithFormat:@"yelp_%f", [self.yelpRating floatValue]]];
    return result;
}

- (NSString *)distanceString {
    return [NSString stringWithFormat:@"%@ miles", self.distance];
}

- (NSString *)formattedPhoneNumber {
    if ([self.phone rangeOfString:@"-"].location == NSNotFound) {
        @try {
            NSString *areaCode = [self.phone substringWithRange:NSMakeRange(0, 3)];
            NSString *part1 = [self.phone substringWithRange:NSMakeRange(3, 3)];
            NSString *part2 = [self.phone substringWithRange:NSMakeRange(6, 4)];
            return [NSString stringWithFormat:@"(%@) %@-%@", areaCode, part1, part2];
        }
        @catch (NSException *exception) {
            return self.phone;
        }
    } else {
        return self.phone;
    }
}

@end
