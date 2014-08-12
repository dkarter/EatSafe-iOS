//
//  AboutTableViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 8/6/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "AboutTableViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface AboutTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *websiteCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *scoreInfoCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dataSourcesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *legalDisclaimerCell;
@property (strong, nonatomic) IBOutlet UITableView *aboutTableView;

@end

@implementation AboutTableViewController

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
    [self.websiteCell.imageView setImage:[[FAKIonIcons ios7HomeOutlineIconWithSize:30]
                                          imageWithSize:CGSizeMake(30, 30)]];
    [self.twitterCell.imageView setImage:[[FAKIonIcons socialTwitterOutlineIconWithSize:30]
                                          imageWithSize:CGSizeMake(30, 30)]];
    [self.emailCell.imageView setImage:[[FAKIonIcons ios7ChatbubbleOutlineIconWithSize:30]
                                          imageWithSize:CGSizeMake(30, 30)]];

    [self.scoreInfoCell.imageView setImage:[[FAKIonIcons ios7PulseIconWithSize:30]
                                          imageWithSize:CGSizeMake(30, 30)]];
    [self.dataSourcesCell.imageView setImage:[[FAKIonIcons ios7LightbulbOutlineIconWithSize:30]
                                          imageWithSize:CGSizeMake(30, 30)]];
    [self.legalDisclaimerCell.imageView setImage:[[FAKIonIcons ios7InformationOutlineIconWithSize:30]
                                        imageWithSize:CGSizeMake(30, 30)]];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tappedCell = [self.aboutTableView cellForRowAtIndexPath:indexPath];
    //website
    if (tappedCell == self.websiteCell) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    @"http://eatsafechicago.com"]];
    } else if (tappedCell == self.twitterCell) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=eatsafechicago"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        @"https://twitter.com/eatsafechicago"]];

        }

    } else if (tappedCell == self.emailCell) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    @"mailto:support@eatsafechicago.com?subject=EatSafe%20Chicago%20Support"]];

    }
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return tableView;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
