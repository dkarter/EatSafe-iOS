//
//  InspectionListDataSourceDelegate.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/16/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "InspectionListDataSourceDelegate.h"

@implementation InspectionListDataSourceDelegate

-(id)init {
    self = [super init];
    self.inspections = [[NSArray alloc] init];
    return self;
}

# pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"InspectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    HealthInspection *currentInspection = self.inspections[indexPath.row];
    
    //get custom cell controls using tags
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *iconLabel =  (UILabel *)[cell.contentView viewWithTag:20];
    UILabel *inspectionTypeLabel =  (UILabel *)[cell.contentView viewWithTag:30];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    dateLabel.text = [dateFormatter stringFromDate:currentInspection.date];
    
    inspectionTypeLabel.text = currentInspection.inspectionType;
    
    iconLabel.attributedText = currentInspection.inspectionResultIcon;
    [iconLabel setBackgroundColor:currentInspection.inspectionResultColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inspections count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
@end
