//
//  PlacesViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 3/3/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "PlacesViewController.h"

@interface PlacesViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *healthInspectionReportsTable;

@end

@implementation PlacesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.healthInspectionReportsTable.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    cell.textLabel.text = self.healthInspectionData[indexPath.row][@"aka_name"];
    cell.detailTextLabel.text = self.healthInspectionData[indexPath.row][@"address"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.healthInspectionData count];
}

@end
