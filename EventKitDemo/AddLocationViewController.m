//
//  AddLocationViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "AddLocationViewController.h"
#import "DBMapSelectorViewController/DBMapSelectorManager.h"
@import INTULocationManager;
double const DEFAULTSPAN = 500;

@interface AddLocationViewController ()<DBMapSelectorManagerDelegate>
@property (nonatomic, strong)DBMapSelectorManager *mapSelectorManager;
@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (assign, nonatomic) INTUHeadingRequestID headingRequestID;
@property (nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic, strong)NSMutableArray *nearbyInfoArray;
@property (nonatomic, strong)NSDictionary *addressBook;
@property (nonatomic, strong)CLPlacemark *place;
@property (nonatomic)BOOL arrive;
@end

@implementation AddLocationViewController
@synthesize rowDescriptor = _rowDescriptor;

- (void)setLocationRequestID:(INTULocationRequestID)locationRequestID
{
    _locationRequestID = locationRequestID;

}
-(void)viewWillAppear:(BOOL)animated {
    [self getCurrentLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapSelectorManager = [[DBMapSelectorManager alloc] initWithMapView:self.mapView];
    self.mapSelectorManager.delegate = self;
    __weak typeof(self) weakself= self;
    weakself.callbackForDidReceiceLocation = ^(CLLocation *currentLocation){
        DDLogDebug(@"call back executed");



        weakself.mapSelectorManager.circleCoordinate = weakself.currentLocation.coordinate;
        weakself.mapSelectorManager.circleRadius = 3000;
        weakself.mapSelectorManager.circleRadiusMax = 25000;
        weakself.mapSelectorManager.circleRadiusMin= 100;
        [weakself.mapSelectorManager applySelectorSettings];
        weakself.mapSelectorManager.editingType = DBMapSelectorEditingTypeFull;
        weakself.mapSelectorManager.fillInside=YES;
     //   weakself.mapSelectorManager.shouldLongPressGesture=YES;
        weakself.mapSelectorManager.shouldShowRadiusText=YES;
        weakself.mapSelectorManager.hidden=NO;
    UIColor *uiColorO = [UIColor orangeColor];
        [weakself mapSelectorManager].fillColor =uiColorO;
        weakself.mapSelectorManager.strokeColor = [UIColor blueColor];

    };

}

-(void)viewWillDisappear:(BOOL)animated {
    [self reverseGeoCode:self.currentLocation];



}


-(void)getCurrentLocation{
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyRoom
                                                                timeout:5.0
                                                   delayUntilAuthorized:YES
                                                                  block:
                                                                          ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                              __typeof(weakSelf) strongSelf = weakSelf;

                                                                              if (status == INTULocationStatusSuccess) {
                                                                                  // achievedAccuracy is at least the desired accuracy (potentially better)

                                                                                  NSString *location = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
                                                                                  DDLogDebug(@"%@",location);

                                                                              }
                                                                              else if (status == INTULocationStatusTimedOut) {
                                                                                  // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                                                                                  NSString *sutt= [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                                                                                  DDLogDebug(@"%@",sutt);
                                                                              }
                                                                              else {
                                                                                  // An error occurred
                                                                                 NSString *string=  [strongSelf getLocationErrorDescription:status];
                                                                                  DDLogDebug(string);
                                                                              }

                                                                              strongSelf.locationRequestID = NSNotFound;
                                                                              weakSelf.currentLocation=currentLocation;

                                                                              if(weakSelf.callbackForDidReceiceLocation){
                                                                                  weakSelf.callbackForDidReceiceLocation(currentLocation);
                                                                              }
                                                                          }];

}

-(void)reverseGeoCode:(CLLocation *)location{
    DDLogDebug(@"start");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
       DDLogInfo(@"Finding address");
        if (error) {
            DDLogDebug(@"Error %@", error.description);
        } else {
            self.place = [placemarks lastObject];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:self.place];
            EKStructuredLocation *location  = [EKStructuredLocation locationWithMapItem:mapItem];
            EKAlarm *alarm1 = [EKAlarm new];
            location.geoLocation= self.currentLocation;
            location.radius=self.mapSelectorManager.circleRadius;
            alarm1.structuredLocation =location;
            alarm1.proximity = (self.arrive)? EKAlarmProximityEnter :EKAlarmProximityLeave;

            [self.delegate addLocation:self didFinishAdding:alarm1];

        }
    }];
    DDLogDebug(@"finish");
}
- (NSString *)getLocationErrorDescription:(INTULocationStatus)status
{
    if (status == INTULocationStatusServicesNotDetermined) {
        return @"Error: User has not responded to the permissions alert.";
    }
    if (status == INTULocationStatusServicesDenied) {
        return @"Error: User has denied this app permissions to access device location.";
    }
    if (status == INTULocationStatusServicesRestricted) {
        return @"Error: User is restricted from using location services by a usage policy.";
    }
    if (status == INTULocationStatusServicesDisabled) {
        return @"Error: Location services are turned off for all apps on this device.";
    }
    return @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
}

-(void)fetchMearByInfo{


    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, self.mapSelectorManager.circleRadius,self.mapSelectorManager.circleRadius );

    MKLocalSearchRequest *requst = [[MKLocalSearchRequest alloc] init];
    requst.region = region;
    requst.naturalLanguageQuery = @"place"; //想要的信息
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:requst];

    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (OBJECT_IS_EMPTY(error))
        {
            [self.nearbyInfoArray addObjectsFromArray:response.mapItems];
            for (MKMapItem * place in response.mapItems) {
                DDLogDebug(@"place: %@",place.name);
            }
        }
        else
        {
            FATAL_CORE_DATA_ERROR(error);
        }
    }];
}

#pragma mark - Actions
- (IBAction)fillingModeSegmentedControlValueDidChange:(UISegmentedControl *)sender {
    self.mapSelectorManager.fillInside = (sender.selectedSegmentIndex == 0);
    self.arrive = (sender.selectedSegmentIndex==0);
    //[self fetchMearByInfo];
}






#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return [self.mapSelectorManager mapView:mapView viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    [self.mapSelectorManager mapView:mapView annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    return [self.mapSelectorManager mapView:mapView rendererForOverlay:overlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapSelectorManager mapView:mapView regionDidChangeAnimated:animated];
}




- (IBAction)finishAddLocation:(id)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];

}

- (XLFormRowDescriptor *)rowDescriptor {
    return nil;
}

- (void)setRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {

}

@end
