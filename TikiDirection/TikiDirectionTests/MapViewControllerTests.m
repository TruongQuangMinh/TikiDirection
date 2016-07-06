//
//  MapViewControllerTests.m
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MapViewController.h"
#import "ABCGooglePlacesSearchViewController.h"
#import "MapViewAnnotation.h"
#import "Location.h"
#import "CommonUtilities.h"
#import "Constants.h"

@interface MapViewController (Test)

@property (nonatomic) UIView *vwDirection;
@property (nonatomic) UITextField *txtStart;
@property (nonatomic) UITextField *txtEnd;
@property (nonatomic) MKMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) Location *startLocation;
@property (nonatomic) Location *endLocation;
@property (nonatomic) MKRoute *routeDetails;

@property (nonatomic) UITextField *txtSelected;
@property (nonatomic) BOOL isUsingCurrentLocation;
@property (nonatomic) BOOL isFirstUpdateLocation;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (void)locationManager: (CLLocationManager *)manager
    didUpdateToLocation: (CLLocation *)newLocation
           fromLocation: (CLLocation *)oldLocation;
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
- (IBAction)onCurrentLocationTap:(id)sender;
- (IBAction)onSwapLocationTap:(id)sender;

@end

@interface MapViewControllerTests : XCTestCase

@property (nonatomic) MapViewController *mapViewController;

@end

@implementation MapViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.mapViewController = [[MapViewController alloc] init];
    self.mapViewController.vwDirection = [[UIView alloc] init];
    self.mapViewController.txtStart = [[UITextField alloc] init];
    self.mapViewController.txtEnd = [[UITextField alloc] init];
    self.mapViewController.mapView = [[MKMapView alloc] init];
}

- (void)tearDown {
    self.mapViewController.vwDirection = nil;
    self.mapViewController.txtStart = nil;
    self.mapViewController.txtEnd = nil;
    self.mapViewController.mapView = nil;
    self.mapViewController = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTextFieldShouldBeginEditing {
    // In case of start textfield
    XCTAssertFalse([self.mapViewController textFieldShouldBeginEditing:self.mapViewController.txtStart], @"TextField should begin editing return NO");
    XCTAssertEqual(self.mapViewController.txtSelected, self.mapViewController.txtStart, @"Selected textField doesn't match with start textField");
    
    // In case of end textfield
    XCTAssertFalse([self.mapViewController textFieldShouldBeginEditing:self.mapViewController.txtEnd], @"TextField should begin editing return NO");
    XCTAssertEqual(self.mapViewController.txtSelected, self.mapViewController.txtEnd, @"Selected textField doesn't match with end textField");
}

- (void)testTextFieldShouldClear {
    // In case of start textfield
    self.mapViewController.startLocation = [[Location alloc] init];
    self.mapViewController.isUsingCurrentLocation = YES;
    [self.mapViewController.txtStart setText:CURRENT_LOCATION];
    XCTAssertFalse([self.mapViewController textFieldShouldClear:self.mapViewController.txtStart], @"TextField should begin editing return NO");
    XCTAssertFalse(self.mapViewController.isUsingCurrentLocation, @"Using current location should be NO");
    XCTAssert([self.mapViewController.txtStart.text isEqualToString:@""], @"Start textfield should be empty");
    XCTAssertNil(self.mapViewController.startLocation, @"Start location should be nil");
    
    // In case of end textfield
    self.mapViewController.endLocation = [[Location alloc] init];
    self.mapViewController.isUsingCurrentLocation = YES;
    [self.mapViewController.txtEnd setText:CURRENT_LOCATION];
    XCTAssertFalse([self.mapViewController textFieldShouldClear:self.mapViewController.txtEnd], @"TextField should begin editing return NO");
    XCTAssertFalse(self.mapViewController.isUsingCurrentLocation, @"Using current location should be NO");
    XCTAssert([self.mapViewController.txtEnd.text isEqualToString:@""], @"Start textfield should be empty");
    XCTAssertNil(self.mapViewController.endLocation, @"Start location should be nil");
}

- (void)testDidUpdateToLocation {
    // Test first updating
    self.mapViewController.startLocation = [[Location alloc] init];
    self.mapViewController.isFirstUpdateLocation = YES;
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:10.796313f longitude:106.658544f];
    CLLocation *oldLocation = [[CLLocation alloc] init];
    [self.mapViewController locationManager:self.mapViewController.locationManager didUpdateToLocation:newLocation fromLocation:oldLocation];

    XCTAssertFalse(self.mapViewController.isFirstUpdateLocation, @"First update location should be NO");
    XCTAssert(((self.mapViewController.startLocation.latitude == newLocation.coordinate.latitude)
              && (self.mapViewController.startLocation.longitude == newLocation.coordinate.longitude)),
                @"Start location should be update for first time");
    
    // Test after moving more than 5 meters
    self.mapViewController.startLocation = [[Location alloc] init];
    self.mapViewController.startLocation.latitude = 9.796313f;
    self.mapViewController.startLocation.longitude = 105.658544f;
    newLocation = [[CLLocation alloc] initWithLatitude:10.796313f longitude:106.658544f];
    [self.mapViewController locationManager:self.mapViewController.locationManager didUpdateToLocation:newLocation fromLocation:oldLocation];
    XCTAssert(((self.mapViewController.startLocation.latitude == newLocation.coordinate.latitude)
               && (self.mapViewController.startLocation.longitude == newLocation.coordinate.longitude)),
              @"Start location should be update after moving more than 5 meters");
}

- (void)testViewForAnnotation {
    // Test annotation is MapViewAnnotation
    MapViewAnnotation *annotation = [[MapViewAnnotation alloc] init];
    MKAnnotationView *annotationView = [self.mapViewController mapView:self.mapViewController.mapView viewForAnnotation:annotation];
    XCTAssertNotNil(annotationView, @"Annotation view should not nil");
}

- (void)testOnCurrentLocationTap {
    [self.mapViewController onCurrentLocationTap:[[UIButton alloc] init]];
    XCTAssertNotNil(self.mapViewController.startLocation, @"Start location should not be nil for current location");
    XCTAssert([self.mapViewController.startLocation.address isEqualToString:CURRENT_LOCATION], @"Address start location should be current location");
    XCTAssertTrue(self.mapViewController.isUsingCurrentLocation, @"Using current location should be YES");
    XCTAssertTrue(self.mapViewController.isFirstUpdateLocation, @"First update location should be YES");
    XCTAssert([self.mapViewController.txtStart.text isEqualToString:self.mapViewController.startLocation.address], @"Start textfield should be update to current location");
}

- (void)testOnSwapLocationTap {
    // Test in case of both locations were selected
    self.mapViewController.startLocation = [[Location alloc] init];
    self.mapViewController.endLocation = [[Location alloc] init];
    Location *startLocationBeforeSwap = self.mapViewController.startLocation;
    Location *endLocationBeforeSwap = self.mapViewController.endLocation;
    [self.mapViewController onSwapLocationTap:[[UIButton alloc] init]];
    
    XCTAssert(self.mapViewController.startLocation == endLocationBeforeSwap, @"Start location should be swapped");
    XCTAssert(self.mapViewController.endLocation == startLocationBeforeSwap, @"End location should be swapped");
    
    // Test in case of only start location was selected
    self.mapViewController.startLocation = [[Location alloc] init];
    self.mapViewController.endLocation = nil;
    startLocationBeforeSwap = self.mapViewController.startLocation;
    [self.mapViewController onSwapLocationTap:[[UIButton alloc] init]];
    
    XCTAssertNil(self.mapViewController.startLocation, @"Start location should be nil after swapping");
    XCTAssert(self.mapViewController.endLocation == startLocationBeforeSwap, @"End location should be swapped");
    
    // Test in case of only end location was selected
    self.mapViewController.startLocation = nil;
    self.mapViewController.endLocation = [[Location alloc] init];
    endLocationBeforeSwap = self.mapViewController.endLocation;
    [self.mapViewController onSwapLocationTap:[[UIButton alloc] init]];
    XCTAssert(self.mapViewController.startLocation == endLocationBeforeSwap, @"Start location should be swapped");
    XCTAssertNil(self.mapViewController.endLocation, @"End location should be nil after swapping");
}

@end
