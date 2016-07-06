//
//  Location.h
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject 

@property (nonatomic, strong) NSString* address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
