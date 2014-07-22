//
//  NoInternetViewController.m
//  SafeToEat
//
//  Created by Dorian Karter on 7/20/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "NoInternetViewController.h"
#import <FAKFontAwesome.h>

@interface NoInternetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noConnectionIconLabel;

@end

@implementation NoInternetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FAKIcon *icon = [FAKFontAwesome unlinkIconWithSize:200];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [self.noConnectionIconLabel setAttributedText:[icon attributedString]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
