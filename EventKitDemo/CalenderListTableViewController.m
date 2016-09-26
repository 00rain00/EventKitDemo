//
//  CalenderListTableViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 26/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//


#import "CalenderListTableViewController.h"
#import "WELDataSource.h"
#import "WELTableDelegate.h"

@interface CalenderListTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) IBOutlet WELDataSource *dataDelegate;


@end

@implementation CalenderListTableViewController

- (void)viewDidLoad {
    DDLogDebug(@"");

    [super viewDidLoad];
    [_dataDelegate addModels:@[@"a",@"b",@"c",@"d"]];
    [_table reloadData];
    _table.delegate = self;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}




@end
