//
//  PizzaPlace.h
//  ZaHunter
//
//  Created by S on 10/15/14.
//  Copyright (c) 2014 Ryan Siska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PizzaPlace : NSObject
@property NSString *nameOfPlace;
@property MKPlacemark *addressCoordinate;
@property CLLocationDistance distanceFromUser;

@end
