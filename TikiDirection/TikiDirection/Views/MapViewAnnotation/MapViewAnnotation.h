//
//  MapViewAnnotation.h
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) BOOL isStartPoint;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString*) title andCoordinate:(CLLocationCoordinate2D)coordinate;
- (MKAnnotationView*)annotationView;

@end
