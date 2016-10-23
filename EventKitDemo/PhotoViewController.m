//
//  PhotoViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "PhotoViewController.h"

NSString * const kNewPhotoAlbum = @"Any New Photo to Album";
NSString * const kAnyNewPhoto = @"Any New Photo";
NSString * const kNewSelfies= @"Any New Selfies";
NSString * const kNewScreenShot = @"Any New Screen Shot";
@interface PhotoViewController ()

@end

@implementation PhotoViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder

{
    DDLogDebug(@"");

    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

-(void)initializeForm{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;

    form = [XLFormDescriptor formDescriptor];
    __typeof(self) __weak weakSelf = self;


    section = [XLFormSectionDescriptor formSectionWithTitle:@"Photo"];
    [form addFormSection:section];
    //album
//    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kNewPhotoAlbum rowType:XLFormRowDescriptorTypeSelectorPush title:@"Ablum"];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Option 1"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Option 3"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Option 4"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Option 5"]
//    ];
//
//    [section addFormRow:row];
    
    //photo
    XLFormRowDescriptor *newPhotoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAnyNewPhoto rowType:XLFormRowDescriptorTypeButton title:kAnyNewPhoto];
    newPhotoRow.action.formBlock=^(XLFormRowDescriptor * sender){
        [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];


    };
    [section addFormRow:newPhotoRow];

    //selfies
    XLFormRowDescriptor *newSelfiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNewSelfies rowType:XLFormRowDescriptorTypeButton title:kNewSelfies];
    newSelfiesRow.action.formBlock=^(XLFormRowDescriptor * sender){
        [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

        
    };
    [section addFormRow:newSelfiesRow];

    
    //screenshot
    XLFormRowDescriptor *newScreenRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNewScreenShot rowType:XLFormRowDescriptorTypeButton title:kNewScreenShot];
    newScreenRow.action.formBlock=^(XLFormRowDescriptor * sender){
        [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

        
    };
    [section addFormRow:newScreenRow];

    self.form = form;



}


@end
