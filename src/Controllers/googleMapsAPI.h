//
//  googleMapsAPI.h
//  Ile sans fil
//
//  Created by Oli on 07/20/09.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


// googleMapsAPIMethods API Methods
typedef enum {
	kGoogleMapsMethodGetCoordFromAddress = 1
} googleMapsAPIMethod;

// Delegate
@protocol googleMapsAPIDelegate <NSObject> 
- (void)googleMapsAPIDidFindCoordinates:(CLLocationCoordinate2D)coordinates;
- (void)googleMapsAPIDidFailWithMessage:(NSString *)message;
@end


@interface googleMapsAPI : NSObject {
	id<googleMapsAPIDelegate> delegate;

	googleMapsAPIMethod currentMethod;
}


@property (nonatomic, assign) id delegate;


- (void)getCoordFromAddress:(NSString *)address;

@end
