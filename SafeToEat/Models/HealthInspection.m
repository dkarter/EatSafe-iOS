//
//  HealthInspection.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/16/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "HealthInspection.h"

@implementation HealthInspection

- (id)initWithJSONObject:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        [self fillFromJSON:JSON];
    }
    return self;
}

- (void)fillFromJSON:(NSDictionary *)JSON {
    self.date               = JSON[@"inspection_date"];
    self.inspectionId       = JSON[@"inspection_id"];
    self.inspectionResult   = JSON[@"inspection_result"];
    self.inspectionType     = JSON[@"inspection_type"];
    self.fullText           = JSON[@"inspection_text"];
}


- (NSString *)inspectionResultString {
    if ([self.inspectionResult isEqual:nil]) {
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


@end
