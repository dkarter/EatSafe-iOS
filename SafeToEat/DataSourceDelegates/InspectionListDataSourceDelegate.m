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
    
    //get custom cell controls using tags
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:10];
    //UILabel *iconLable =  (UILabel *)[cell.contentView viewWithTag:20];
    
    dateLabel.text = @"Pizza!";//[NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:[(HealthInspection *)self.inspections[indexPath.row] date]
                       //                                                               dateStyle:NSDateFormatterShortStyle
                         //                                                             timeStyle:NSDateFormatterNoStyle]];
    
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
