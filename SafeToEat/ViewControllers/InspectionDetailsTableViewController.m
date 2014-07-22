//
//  InspectionDetailsTableViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/18/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "InspectionDetailsTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface InspectionDetailsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *inspectionResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *inspectionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *inspectionTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *inspectionTextView;

@end

@implementation InspectionDetailsTableViewController {
    MBProgressHUD *hud;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.inspectionData isEqual:nil]) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataRetrieved)
                                                     name:@"initInspectionWithJSONWithIdFinishedLoading"
                                                   object:nil];
        
        self.inspectionResultLabel.text = self.inspectionData.inspectionResultString;
        [self.inspectionResultLabel setTextColor:self.inspectionData.inspectionResultColor];
        self.inspectionTypeLabel.text = self.inspectionData.inspectionType;
        self.inspectionDateLabel.text = self.inspectionData.inspectionDateString;
        
        self.inspectionData = [[HealthInspection alloc]
                               initWithJSONWithId:self.inspectionData.inspectionId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [super tableView:tableView numberOfRowsInSection:section];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


- (void)dataRetrieved {
    self.inspectionTextView.text = self.inspectionData.fullText;
    
    [hud hide:YES];
}

@end
