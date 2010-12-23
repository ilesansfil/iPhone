//
//  Location.h
//  Ile sans fil
//
//  Created by Oli on 12/06/09.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Hotspot;

@interface LocationAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	NSString *shortname;
	Hotspot	*hotspot;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *shortname;
@property (nonatomic, retain) Hotspot	*hotspot;

@end
