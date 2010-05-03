//
//  MapViewController.h
//  Ile sans fil
//
//  Created by Oli on 11/06/09.
//  Copyright 2009 Kolt Production. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "googleMapsAPI.h"
#import "XMLReader.h"


@class BanksViewController, LocationAnnotation;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, googleMapsAPIDelegate, XMLReaderDelegate> {
	IBOutlet MKMapView 					*map;
	IBOutlet UIView 						*searchingView;
	IBOutlet UIActivityIndicatorView *loadingLocationsView;
	IBOutlet UISearchBar 				*addressSearchBar;
	IBOutlet UITextField 				*addressSearchBarTextField;
	IBOutlet UILabel 						*locatingLabel;

	NSOperationQueue *operationQueue;

	LocationAnnotation	*currentLocation;
	LocationAnnotation	*searchLocation;
	googleMapsAPI 			*gMapsAPI;

	UIView *noHotspotView;

	BOOL isFirstLaunch;
	BOOL initialized;
	BOOL zoomingToLocation;
	BOOL locatingMe;
	BOOL searchingLocation;
	BOOL loadingMap;
	BOOL currentLocationInMap;
	BOOL locationInView;
	BOOL updatingLocations;
	BOOL needsZoomOut;
}

- (IBAction)locateMe;
- (CLLocationCoordinate2D) getCurrentCoordinate;
@end
