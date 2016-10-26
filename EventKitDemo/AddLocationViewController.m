//
//  AddLocationViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "AddLocationViewController.h"
#import "DBMapSelectorViewController/DBMapSelectorManager.h"
#import "CoreDataService.h"
@import INTULocationManager;


double const DEFAULTSPAN = 500;
NSString *const klocationlongtitude = @"locationLongtitude";
NSString *const klocationlatitude=@"locationLatitude";
NSString *const kradius = @"locationRadius";
NSString *const klocation = @"locationAddress";
NSString *const klocationType = @"locationType";
NSString *const kdisplay  =@"LocationDisplay";
NSString *const klocationDetails = @"LocationDetails";

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
@property (nonatomic, strong)MKMapItem *closeAddress;
@end

@implementation AddLocationViewController {
    DBMapSelectorManager *_mapSelectorManager;
}
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
        weakself.mapSelectorManager.circleRadius = 500;
        weakself.mapSelectorManager.circleRadiusMax = 25000;
        weakself.mapSelectorManager.circleRadiusMin= 100;
        [weakself.mapSelectorManager applySelectorSettings];
        weakself.mapSelectorManager.editingType = DBMapSelectorEditingTypeFull;
        weakself.mapSelectorManager.fillInside=YES;

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
//            self.place = [placemarks lastObject];
//            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:self.place];
//            EKStructuredLocation *locationn  = [EKStructuredLocation locationWithMapItem:mapItem];
//            EKAlarm *alarm1 = [EKAlarm new];
//            locationn.geoLocation= self.currentLocation;
//            locationn.radius=self.mapSelectorManager.circleRadius;
//            alarm1.structuredLocation =locationn;
//            alarm1.proximity = (self.arrive)? EKAlarmProximityEnter :EKAlarmProximityLeave;
//
//            [self.delegate addLocation:self didFinishAdding:alarm1];

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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    // Set the label text.
    hud.label.text = NSLocalizedString(@"Saving...", @"HUD loading title");


    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{

        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, self.mapSelectorManager.circleRadius,self.mapSelectorManager.circleRadius );

        MKLocalSearchRequest *requst = [[MKLocalSearchRequest alloc] init];
        requst.region = region;
        requst.naturalLanguageQuery = @"place"; //想要的信息
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:requst];
        __weak typeof(self) weakSelf=self;
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
            if (OBJECT_IS_EMPTY(error))
            {
                [weakSelf.nearbyInfoArray addObjectsFromArray:response.mapItems];
                weakSelf.closeAddress = response.mapItems.firstObject;


            for (MKMapItem * place in response.mapItems) {
                DDLogDebug(@"place: %@",place.name);
            }
            }
            else
            {
                FATAL_CORE_DATA_ERROR(error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                sleep(5);
                [weakSelf saveLocation];
                [hud hideAnimated:YES];
                [weakSelf.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                
            });

        }];
        

    });


}

#pragma mark - Actions
- (IBAction)fillingModeSegmentedControlValueDidChange:(UISegmentedControl *)sender {
    self.mapSelectorManager.fillInside = (sender.selectedSegmentIndex == 0);
    self.arrive = (sender.selectedSegmentIndex==0);

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
    
    [self fetchMearByInfo];


}

-(void)saveLocation{
    NSString *reminderId = [[NSUserDefaults standardUserDefaults] valueForKey:@"selected_reminder_identifier"];
    if(OBJECT_IS_EMPTY(reminderId)){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }else{
        if([self saveValidation:reminderId]){
            __weak typeof(self) weakSelf=self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops" message:@"We found that there is/are condition(s) repeating! \n Please delete the exsit one then add a new condition" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
                [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

            }]];
            [alertController show];
        }else{
//            while (OBJECT_IS_EMPTY(self.nearbyInfoArray)) {
//                DDLogDebug(@"");
//            };
            CoreDataService *coreDataService = [[CoreDataService alloc] init];

            NSString * displayString;
            if(self.editingTypeSegentedControl.selectedSegmentIndex== (NSInteger) @(0)){
                displayString  = [NSString stringWithFormat:@"%@ %@",@"arriving",self.closeAddress.name];
            }else{
                displayString  = [NSString stringWithFormat:@"%@ %@",@"leaving",self.closeAddress.name];
            }
            DDLogDebug(displayString);
            NSDictionary *locationDetails = [ NSDictionary new];
            
            
            
            if(OBJECT_IS_EMPTY(self.nearbyInfoArray)){
                DDLogDebug(@"nearByinfo arra y empty");
                locationDetails  = @{
                                     klocationlatitude:@(self.mapSelectorManager.circleCoordinate.latitude),
                                     klocationlongtitude: @(self.mapSelectorManager.circleCoordinate.longitude),
                                     kradius:@(self.mapSelectorManager.circleRadius),
                                     klocationType:@(self.editingTypeSegentedControl.selectedSegmentIndex),
                                    
                                     kdisplay:displayString
                                     
                                     
                                     };
                
            }else{
                locationDetails  = @{
                                     klocationlatitude:@(self.mapSelectorManager.circleCoordinate.latitude),
                                     klocationlongtitude: @(self.mapSelectorManager.circleCoordinate.longitude),
                                     kradius:@(self.mapSelectorManager.circleRadius),
                                     klocationType:@(self.editingTypeSegentedControl.selectedSegmentIndex),
                                     klocation:self.nearbyInfoArray,
                                     kdisplay:displayString
                                     
                                     
                                     };

                
            }
            

                       NSData *data = [NSKeyedArchiver archivedDataWithRootObject:locationDetails];
            [coreDataService createCondition:reminderId :klocationDetails :data];

            coreDataService= nil;




        }






    }
}



-(BOOL)saveValidation:(NSString *)reminderID{
    BOOL flag  = NO;
    CoreDataService *coreDataService = [[CoreDataService alloc] init];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =reminderID;
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    NSArray *result =  [coreDataService fetchCondition:request];
    for(Condition * condition in result){
        if([condition.myKey isEqualToString:klocationlatitude]||[condition.myKey isEqualToString:klocationlatitude]||[condition.myKey isEqualToString:kradius]||[condition.myKey isEqualToString:klocation]||[condition.myKey isEqualToString:klocationType]){
            flag = YES;
            break;
        }
    }
    coreDataService=nil;
    return flag;
}
- (XLFormRowDescriptor *)rowDescriptor {
    return nil;
}

- (void)setRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {

}

@end
