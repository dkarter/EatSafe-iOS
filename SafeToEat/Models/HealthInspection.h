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

@property (strong, nonatomic) NSString *fullText;
@property (strong, nonatomic) NSString *inspectionType;

//readonly getters
@property (strong, nonatomic, readonly) UIColor *inspectionResultColor;
@property (readonly, strong, nonatomic) NSString *inspectionResultString;
@property (strong, nonatomic, readonly) NSAttributedString *inspectionResultIcon;
@property (strong, nonatomic, readonly) NSString *inspectionDateString;

//initializers
- (id)initWithJSONWithId:(NSNumber *)inspectionId;
- (id)initWithJSONObject:(NSDictionary *)JSON;
@end
