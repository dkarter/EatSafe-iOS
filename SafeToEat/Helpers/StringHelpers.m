//
//  StringHelpers.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/13/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "StringHelpers.h"

@implementation StringHelpers

+(BOOL)isEmpty:(NSString *)str
{
    if([str length] == 0 || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@""]||[str isEqualToString:NULL]||[str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"]){
        return YES;
    }
    return NO;
}

@end
