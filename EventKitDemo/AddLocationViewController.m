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

@interface AddLocationViewController ()<DBMapSelectorManagerDelegate>
@property (nonatomic, strong)DBMapSelectorManager *mapSelectorManager;
@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (assign, nonatomic) INTUHeadingRequestID headingRequestID;
@property (nonatomic, strong)CLLocation *currentLocation;

@end

@implementation AddLocationViewController

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



@end
