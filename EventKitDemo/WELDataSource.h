//
//  WELDataSource.h
//  EventKitDemo
//
//  Created by YULIN CAI on 27/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WELCellConfigure.h"



typedef void (^CellConfigureBefore)(id cell, id model, NSIndexPath * indexPath);


IB_DESIGNABLE
@interface WELDataSource : NSObject <UITableViewDataSource,UICollectionViewDataSource>

//--------- For Code
- (id)initWithIdentifier:(NSString *)identifier configureBlock:(CellConfigureBefore)before;

//--------- For StoryBoard

@property (nonatomic, strong) IBInspectable NSString *cellIdentifier;

@property (nonatomic, copy) CellConfigureBefore cellConfigureBefore;

//---------Public

- (void)addModels:(NSArray *)models;

- (id)modelsAtIndexPath:(NSIndexPath *)indexPath;



@end