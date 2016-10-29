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

#import "EditEventViewController.h"
double const DEFAULTSPAN = 500;
NSString *const klocationlongtitude = @"locationLongtitude";
NSString *const klocationlatitude=@"locationLatitude";
NSString *const kradius = @"locationRadius";
NSString *const klocation = @"locationAddress";
NSString *const klocationType = @"locationType";
NSString *const kdisplay  =@"LocationDisplay";
NSString *const klocationDetails = @"LocationDetails";

@interface AddLocationViewController ()<DBMapSelectorManagerDelegate>
{
@private
    CGRect _searchTableViewRect;
}
@property (nonatomic, strong)DBMapSelectorManager *mapSelectorManager;
@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (nonatomic, strong)CoreDataService *cd;
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
    self.cd = [[CoreDataService alloc] init];
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
// Keep the subviews inside the top and bottom layout guides
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    // Fix black glow on navigation bar
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];


    // Set up search operators
    [self setupSearchController];
    [self setupSearchBar];

    // Should make search bar extend underneath status bar (DOES NOT WORK)
    self.definesPresentationContext = YES;



}

-(void)setupLocationManager{

}

-(void)setupSearchController{

    // The TableViewController used to display the results of a search
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.automaticallyAdjustsScrollViewInsets = NO; // Remove table view insets
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;

    // Initialize our UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;


}
-(void) setupSearchBar {

    // Set search bar dimension and position
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    CGRect viewFrame = self.view.frame;
    self.searchController.searchBar.frame = CGRectMake(searchBarFrame.origin.x,
            searchBarFrame.origin.y,
            viewFrame.size.width,
            44.0);

    // Add SearchController's search bar to our view and bring it to front
    [self.view addSubview:self.searchController.searchBar];
    [self.view bringSubviewToFront:self.searchController.searchBar];

}
- (void)searchQuery:(NSString *)query {
    // Cancel any previous searches.
    [self.localSearch cancel];

    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    request.region = self.mapView.region;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];

    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (OBJECT_ISNOT_EMPTY(error)) {
            __weak typeof(self) weakSelf=self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops" message:@"Internet connection error" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
                [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

            }]];
            [alertController show];
            return;
        }

        //			if ([response.mapItems count] == 0) {
        //				[[[UIAlertView alloc] initWithTitle:@"No Results"
        //											message:nil
        //										   delegate:nil
        //								  cancelButtonTitle:@"OK"
        //								  otherButtonTitles:nil] show];
        //				return;
        //			}

        self.results = response;

        [[(UITableViewController *)self.searchController.searchResultsController tableView] reloadData];
    }];
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

        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(self.mapSelectorManager.circleCoordinate, self.mapSelectorManager.circleRadius,self.mapSelectorManager.circleRadius );

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
               
                [weakSelf saveLocation];
                [hud hideAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];

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

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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


            NSString * displayString;
            if(self.editingTypeSegentedControl.selectedSegmentIndex==0){
                displayString  = [NSString stringWithFormat:@"%@ %@",@"Inside",self.closeAddress.name];
            }else{
                displayString  = [NSString stringWithFormat:@"%@ %@",@"Outside",self.closeAddress.name];
            }
            DDLogDebug(displayString);
            NSDictionary *locationDetails = [NSDictionary new];
            
            
            
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
            [self.cd createCondition:reminderId :klocationDetails :data];

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
        if([condition.myKey isEqualToString:klocationDetails]){
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


- (void)willPresentSearchController:(UISearchController *)aSearchController {

    aSearchController.searchBar.bounds = CGRectInset(aSearchController.searchBar.frame, 0.0f, 0.0f);

    // Set the position of the result's table view below the status bar and search bar
    // Use of instance variable to do it only once, otherwise it goes down at every search request
    if (CGRectIsEmpty(_searchTableViewRect)) {
        CGRect tableViewFrame = ((UITableViewController *)aSearchController.searchResultsController).tableView
                .frame;
        tableViewFrame.origin.y = tableViewFrame.origin.y + 64; //status bar (20) + nav bar (44)
        tableViewFrame.size.height =  tableViewFrame.size.height;

        _searchTableViewRect = tableViewFrame;
    }

    [((UITableViewController *)aSearchController.searchResultsController).tableView setFrame:_searchTableViewRect];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (OBJECT_ISNOT_EMPTY(searchText)) {
        [self searchQuery:searchText];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self searchQuery:aSearchBar.text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *IDENTIFIER = @"SearchResultsCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }

    MKMapItem *item = self.results.mapItems[(NSUInteger) indexPath.row];

    cell.textLabel.text = item.placemark.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Hide search controller
    [self.searchController setActive:NO];

    MKMapItem *item = self.results.mapItems[(NSUInteger) indexPath.row];

    DDLogDebug(@"Selected \"%@\"", item.placemark.name);


    self.mapSelectorManager.circleCoordinate = item.placemark.location.coordinate;

    self.mapSelectorManager.circleRadius = 500;
    self.mapSelectorManager.circleRadiusMax = 25000;
    self.mapSelectorManager.circleRadiusMin= 100;
    [self.mapSelectorManager applySelectorSettings];
    self.mapSelectorManager.editingType = DBMapSelectorEditingTypeFull;
    self.mapSelectorManager.fillInside=YES;

    self.mapSelectorManager.shouldShowRadiusText=YES;
    self.mapSelectorManager.hidden=NO;
    UIColor *uiColorO = [UIColor orangeColor];
    [self mapSelectorManager].fillColor =uiColorO;
    self.mapSelectorManager.strokeColor = [UIColor blueColor];
//    [self.mapView addAnnotation:item.placemark];
//    [self.mapView selectAnnotation:item.placemark animated:YES];
//
//    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
//
//    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];

}


@end
