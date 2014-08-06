//
//  HealthInspection.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/16/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "HealthInspection.h"
#import "FontAwesomeKit/FontAwesomeKit.h"
#import "AFNetworking.h"

@implementation HealthInspection

- (id)initWithJSONWithId:(NSString *)inspectionId {
    self = [super init];
    if (self) {
        NSString *restaurantURL = @"%@/inspection?id=%@";
        
        NSString *urlString = [NSString stringWithFormat:restaurantURL,
                               kESBaseURL, inspectionId];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
            
            [self fillFromJSON:JSON];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"initInspectionWithJSONWithIdFinishedLoading"
             object:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Cannot retrieve inspection: %@", error.localizedDescription);
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *inspectionDate = [dateFormatter dateFromString:JSON[@"inspection_date"]];

    self.date               = inspectionDate;
    self.inspectionId       = JSON[@"inspection_id"];
    self.inspectionResult   = JSON[@"inspection_results_num"];
    self.inspectionType     = JSON[@"inspection_type"];
    self.fullText           = [JSON[@"inspection_text"] isKindOfClass:[NSNull class]] ? @"" : JSON[@"inspection_text"];


}


- (NSString *)inspectionResultString {
    if ([self.inspectionResult isKindOfClass:[NSNull class]]) {
        return @"No Entry";
    } else {
        
        switch ([self.inspectionResult intValue]) {
            case 100:
                return @"Passed";
            case 90:
                return @"Passed w/ Conditions";
            case 0:
                return @"Failed";
            default:
                return @"Error";
        }
    
    }
}

- (NSAttributedString *)inspectionResultIcon {

    if ([self.inspectionResult isKindOfClass:[NSNull class]]) {
        return [[FAKFontAwesome questionIconWithSize:15] attributedString];
    } else {
        
        switch ([self.inspectionResult intValue]) {
            case 100:
                return [[FAKFontAwesome checkIconWithSize:15] attributedString];
            case 90:
                return [[FAKFontAwesome exclamationIconWithSize:15] attributedString];
            case 0:
                return [[FAKFontAwesome timesIconWithSize:15] attributedString];;
            default:
                return [[FAKFontAwesome questionIconWithSize:15] attributedString];;
        }
        
    }

}

- (UIColor *)inspectionResultColor {
    float baseColor = 255.0f;
    NSDictionary *inspectionResultColorDict = @{@"Passed": [UIColor colorWithRed:57.0f/baseColor green:181.0f/baseColor blue:74.0f/baseColor alpha:1],
                                                @"Passed w/ Conditions": [UIColor colorWithRed:171.0f/baseColor green:219.0f/baseColor blue:69.0f/baseColor alpha:1],
                                                @"Failed": [UIColor colorWithRed:237.0f/baseColor green:28.0f/baseColor blue:36.0f/baseColor alpha:1],
                                                @"No Entry": [UIColor lightGrayColor]};

    if ([self.inspectionResult isKindOfClass:[NSNull class]]) {
        return [UIColor lightGrayColor];
    } else {
        return [inspectionResultColorDict valueForKey:self.inspectionResultString];
    }
}

- (NSString *)inspectionDateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    return [dateFormatter stringFromDate:self.date];

}

@end
