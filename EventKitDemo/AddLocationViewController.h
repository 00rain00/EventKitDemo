//
//  AddLocationViewController.h
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <MapKit/MapKit.h>
@class AddLocationViewController;

@protocol AddLocationViewControllerDelegate<NSObject>
-(void)addLocation:(AddLocationViewController *)controller didFinishAdding:(EKAlarm *)item;
@end
typedef void(^DidReceiveLocation)(CLLocation *currentlocation);
@interface AddLocationViewController : UIViewController<MKMapViewDelegate>
@property(nonatomic,weak)IBOutlet MKMapView *mapView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *editingTypeSegentedControl;
@property (nonatomic, strong)DidReceiveLocation callbackForDidReceiceLocation;
@property (nonatomic,weak) id <AddLocationViewControllerDelegate> delegate;
@end
