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
#import <XLForm/XLForm.h>

@class AddLocationViewController;

@protocol AddLocationViewControllerDelegate<NSObject>
-(void)addLocation:(AddLocationViewController *)controller didFinishAdding:(EKAlarm *)item;
@end
typedef void(^DidReceiveLocation)(CLLocation *currentlocation);
@interface AddLocationViewController : UIViewController<MKMapViewDelegate,
        XLFormRowDescriptorViewController,
        UISearchBarDelegate,
        UISearchControllerDelegate,
        CLLocationManagerDelegate,
        UITableViewDataSource,
        UITableViewDelegate>
@property(nonatomic,weak)IBOutlet MKMapView *mapView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *editingTypeSegentedControl;
@property (nonatomic, strong)DidReceiveLocation callbackForDidReceiceLocation;
@property (nonatomic, copy)NSString *locationType;
@property (nonatomic,weak) id <AddLocationViewControllerDelegate> delegate;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *results;


- (void)viewDidLoad;

- (IBAction)finishAddLocation:(id)sender;
-(IBAction)back:(id)sender;
@end
