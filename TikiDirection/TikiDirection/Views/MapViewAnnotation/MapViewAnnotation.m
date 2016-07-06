//
//  MapViewAnnotation.m
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

-(id) initWithTitle:(NSString *) title andCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self) {
        _title = title;
        _coordinate = coordinate;
    }
    
    return self;
}

- (MKAnnotationView*)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MapViewAnnotation"];
    
    UIImage *imgPoint;
    if (self.isStartPoint) {
        imgPoint = [UIImage imageNamed:@"ic_startPoint"];
        
    } else {
        imgPoint = [UIImage imageNamed:@"ic_endPoint"];
    }
    annotationView.frame=CGRectMake(0, 0, imgPoint.size.width, imgPoint.size.height);
    
    UIImageView *imvPoint=[[UIImageView alloc] init];
    imvPoint.frame = CGRectMake(0, 0, imgPoint.size.width, imgPoint.size.height);
    imvPoint.image = imgPoint;

    [annotationView addSubview:imvPoint];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

@end
