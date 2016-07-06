//
//  MapViewController.m
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import "MapViewController.h"
#import "ABCGooglePlacesSearchViewController.h"
#import "MapViewAnnotation.h"
#import "Location.h"
#import "CommonUtilities.h"
#import "Constants.h"

@interface MapViewController ()<ABCGooglePlacesSearchViewControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *vwDirection;
@property (weak, nonatomic) IBOutlet UITextField *txtStart;
@property (weak, nonatomic) IBOutlet UITextField *txtEnd;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Location *startLocation;
@property (strong, nonatomic) Location *endLocation;
@property (strong, nonatomic) MKRoute *routeDetails;

@property (weak, nonatomic) UITextField *txtSelected;
@property (assign, nonatomic) BOOL isUsingCurrentLocation;
@property (assign, nonatomic) BOOL isFirstUpdateLocation;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initiate Methods
-(void)setUp {
    [self initLocationManager];
}

-(void)initLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Show SearchViewController to select location
    self.txtSelected = textField;
    [self showSearchViewController];
    return  NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    // Clear selected location and stop updating location manager if current location was selected
    if ([textField.text isEqualToString:CURRENT_LOCATION]) {
        [_locationManager stopUpdatingLocation];
        self.isUsingCurrentLocation = NO;
    }
    
    [textField setText:@""];
    if (textField == self.txtStart) {
        self.startLocation = nil;
    } else if (textField == self.txtEnd) {
        self.endLocation = nil;
    }
    
    [self clearRoutingAndAnnotations];
    
    return NO;
}

#pragma mark - LocationManager Delegate
- (void)locationManager: (CLLocationManager *)manager
    didUpdateToLocation: (CLLocation *)newLocation
           fromLocation: (CLLocation *)oldLocation
{
    if (self.isFirstUpdateLocation) {
        self.isFirstUpdateLocation = NO;
        
        self.startLocation.latitude = newLocation.coordinate.latitude;
        self.startLocation.longitude = newLocation.coordinate.longitude;
    }
    
    // Check current location if the location was swapped to end point
    Location *currentLocation;
    if ([self.txtEnd.text isEqualToString:CURRENT_LOCATION]) {
        currentLocation = self.endLocation;
    } else {
        currentLocation = self.startLocation;
    }
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    CLLocationDistance distance = [userLocation distanceFromLocation:newLocation];
    
    // Update location after moving 5 meters
    if (distance > 5.0f) {
        self.startLocation.latitude = newLocation.coordinate.latitude;
        self.startLocation.longitude = newLocation.coordinate.longitude;
        
        // Auto drawing if the both location was selected
        if (self.startLocation && self.endLocation) {
            [self clearRoutingAndAnnotations];
            [self drawRoutingLocations];
        }
    }
}

#pragma mark - MapView Delegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor colorWithHexString:@"00ACF0"];
    routeLineRenderer.lineWidth = 3;
    return routeLineRenderer;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
        MapViewAnnotation *myLocation = (MapViewAnnotation*)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapViewAnnotation"];
        annotationView = [myLocation annotationView];
        
        return annotationView;
    }
    return nil;
}

#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods
-(void)searchViewController:(ABCGooglePlacesSearchViewController *)controller didReturnPlace:(ABCGooglePlace *)place {
    // Clear current location if it was selected
    if ([self.txtSelected.text isEqualToString:CURRENT_LOCATION]) {
        [_locationManager stopUpdatingLocation];
        self.isUsingCurrentLocation = NO;
    }
    
    // Update selected location
    [self.txtSelected setText:place.formatted_address];
    
    if (self.txtSelected == self.txtStart) {
        self.startLocation = [[Location alloc] init];
        self.startLocation.address = place.formatted_address;
        self.startLocation.latitude = place.location.coordinate.latitude;
        self.startLocation.longitude = place.location.coordinate.longitude;
    } else if (self.txtSelected == self.txtEnd) {
        self.endLocation = [[Location alloc] init];
        self.endLocation.address = place.formatted_address;
        self.endLocation.latitude = place.location.coordinate.latitude;
        self.endLocation.longitude = place.location.coordinate.longitude;
    }
    
    // Auto drawing a route in map if the both locations were selected
    if (self.startLocation && self.endLocation) {
        [self clearRoutingAndAnnotations]; // Clear old drawing
        [self drawRoutingLocations];
    }
}

#pragma mark - Actions Methods
- (IBAction)onShowDirectionTap:(id)sender {
    if (self.vwDirection.frame.origin.y > 0) {
        // Hide direction view
        [UIView moveVerticalView:self.vwDirection withRange:-100];
    } else {
        // Show direction view
        [UIView moveVerticalView:self.vwDirection withRange:100];
    }
}

- (IBAction)onCurrentLocationTap:(id)sender {
    // Init current location if not exist
    if (!self.isUsingCurrentLocation) {
        self.startLocation = [[Location alloc] init];
        self.startLocation.address = CURRENT_LOCATION;
        
        self.isUsingCurrentLocation = YES;
        self.isFirstUpdateLocation = YES;
        [self.txtStart setText:self.startLocation.address];
        
        [self.locationManager startUpdatingLocation];
    }
}

- (IBAction)onSwapLocationTap:(id)sender {
    if (self.startLocation && self.endLocation) { // In case of both locations were selected
        Location *tempLocation = self.startLocation;
        self.startLocation = self.endLocation;
        self.endLocation = tempLocation;
        
        NSString *tempAddress = self.txtStart.text;
        [self.txtStart setText:self.txtEnd.text];
        [self.txtEnd setText: tempAddress];
        
        // Reverse a route in map
        [self clearRoutingAndAnnotations];
        [self drawRoutingLocations];
    } else if (self.startLocation && !self.endLocation) { // In case of only start location was selected
        self.endLocation = self.startLocation;
        self.startLocation = nil;
        
        [self.txtEnd setText:self.txtStart.text];
        [self.txtStart setText:@""];
    } else if (!self.startLocation && self.endLocation) { // In case of only end location was selected
        self.startLocation = self.endLocation;
        self.endLocation = nil;
        
        [self.txtStart setText:self.txtEnd.text];
        [self.txtEnd setText:@""];
    }
}

#pragma mark - Main Functions
-(void)showSearchViewController {
    ABCGooglePlacesSearchViewController *searchViewController = [[ABCGooglePlacesSearchViewController alloc] init];
    [searchViewController setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)drawRoutingLocations {
    [self showMapViewAnnotations];
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.startLocation.latitude, self.startLocation.longitude) addressDictionary:nil];
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.endLocation.latitude, self.endLocation.longitude) addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:startPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:endPlacemark]];
    
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error");
        } else {
            self.routeDetails = response.routes.lastObject;
            [self.mapView addOverlay:self.routeDetails.polyline];
        }
    }];
}

-(void)showMapViewAnnotations {
    NSArray *arrAnnotations = [self createCustomAnnotations];
    [self.mapView addAnnotations:arrAnnotations];
    [self showFullLocationInMapViewWithArray:arrAnnotations];
}

- (NSArray *)createCustomAnnotations
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D startCoord;
    startCoord.latitude = self.startLocation.latitude;
    startCoord.longitude = self.startLocation.longitude;
    MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:self.startLocation.address andCoordinate:startCoord];
    startAnnotation.isStartPoint = YES;
    
    CLLocationCoordinate2D endCoord;
    endCoord.latitude = self.endLocation.latitude;
    endCoord.longitude = self.endLocation.longitude;
    MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:self.endLocation.address andCoordinate:endCoord];
    endAnnotation.isStartPoint = NO;
    
    [annotations addObject:startAnnotation];
    [annotations addObject:endAnnotation];
    
    return annotations;
}

- (void)showFullLocationInMapViewWithArray:(NSArray *)array {
    float Lat_Min = 0, Lat_Max = 0;
    float Long_Max = 0, Long_Min = 0;
    
    MapViewAnnotation *recommend = [array objectAtIndex:0];
    Lat_Min = recommend.coordinate.latitude;
    Lat_Max = recommend.coordinate.latitude;
    Long_Min = recommend.coordinate.longitude;
    Long_Max = recommend.coordinate.longitude;
    
    for (int i = 1; i < array.count; i++) {
        MapViewAnnotation *recommend = [array objectAtIndex:i];
        CLLocationCoordinate2D nearMe = CLLocationCoordinate2DMake(recommend.coordinate.latitude, recommend.coordinate.longitude);
        if (Lat_Max < nearMe.latitude) {
            Lat_Max = nearMe.latitude;
        }
        else if (Lat_Min > nearMe.latitude) {
            Lat_Min = nearMe.latitude;
        }
        
        if (Long_Max < nearMe.longitude) {
            Long_Max = nearMe.longitude;
        }
        else if (Long_Min > nearMe.longitude) {
            Long_Min = nearMe.longitude;
        }
    }
    
    CLLocationCoordinate2D min = CLLocationCoordinate2DMake(Lat_Min, Long_Min);
    CLLocationCoordinate2D max = CLLocationCoordinate2DMake(Lat_Max, Long_Max);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((max.latitude + min.latitude) / 2.0, (max.longitude + min.longitude) / 2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(max.latitude - min.latitude + 0.005f, max.longitude - min.longitude + 0.005f);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
}

- (void)clearRoutingAndAnnotations {
    if (self.routeDetails) {
        [self.mapView removeOverlay:self.routeDetails.polyline];
    }
    
    if (self.mapView.annotations.count > 0) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
}

@end
