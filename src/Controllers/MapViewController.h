//
//  MapViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "googleMapsAPI.h"
#import "XMLReader.h"


@class BanksViewController, LocationAnnotation;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate,/* googleMapsAPIDelegate,*/ XMLReaderDelegate> {
	IBOutlet MKMapView 					*map;
	IBOutlet UIView 						*searchingView;
	IBOutlet UIActivityIndicatorView *loadingLocationsView;
	IBOutlet UISearchBar 				*addressSearchBar;
	IBOutlet UITextField 				*addressSearchBarTextField;
	IBOutlet UILabel 						*locatingLabel;
	IBOutlet UITableView					*tableViewHotspot;
	IBOutlet UINavigationBar				*_navBar;
	IBOutlet UINavigationItem				*_navItem;
	IBOutlet UIView							*connectionView;
	IBOutlet UIView							*principalView;
	IBOutlet UIButton						*BtLocateme;
	IBOutlet UILabel						*alertMain;
	IBOutlet UILabel						*alertMessage;
	
	UIView * barButtonSuperView, * barButtonPrimaryView, * barButtonSecondaryView;

	
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.	
    BOOL			searchWasActive;
	
	NSOperationQueue *operationQueue;
	
	NSMutableArray *hotspotArray;
	LocationAnnotation	*currentLocation;
	LocationAnnotation	*searchLocation;
//	googleMapsAPI 			*gMapsAPI;

	UIView *noHotspotView;

	BOOL isMapView;
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


@property (nonatomic, retain) NSMutableArray *hotspotArray;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic) BOOL searchWasActive;

- (IBAction)locateMe;
- (CLLocationCoordinate2D) getCurrentCoordinate;
- (IBAction)showList;
-(void)searchTableView:(NSString*)searchText;
@end


