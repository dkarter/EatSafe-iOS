//
//  HealthInspection.h
//  SafeToEat
//
//  Created by Dorian Karter on 7/16/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthInspection : NSObject

@property (strong, nonatomic) NSNumber *inspectionId;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *inspectionResult;
@property (readonly, strong, nonatomic) NSString *inspectionResultString;
@property (strong, nonatomic) NSString *fullText;
@property (strong, nonatomic) NSString *inspectionType;

- (id)initWithJSONObject:(NSDictionary *)JSON;
@end
