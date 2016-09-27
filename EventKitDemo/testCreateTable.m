//
//  testCreateTable.m
//  EventKitDemo
//
//  Created by YULIN CAI on 27/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "testCreateTable.h"
#import "WELDataSource.h"
#import "WELTableDelegate.h"
#import "Event.h"
@interface testCreateTable()
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) IBOutlet WELDataSource *dataDelegate;


    
@end


@implementation testCreateTable

- (void)viewDidLoad {
    DDLogDebug(@"");
    
    [super viewDidLoad];
    Event *newEvent = [Event new];
    newEvent.index=1;
    newEvent.name=@"A";
NSMutableArray *data = [NSMutableArray new];
    [data addObject:newEvent];
    [_dataDelegate addModels: data];
    [_table reloadData];
    _table.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
