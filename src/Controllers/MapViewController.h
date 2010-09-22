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


@class /*BanksViewController,*/ LocationAnnotation;
@class EGORefreshTableHeaderView;

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
	IBOutlet UIButton						*BtRefresh;
	IBOutlet UILabel						*alertMain;
	IBOutlet UILabel						*alertMessage;
	
	UIView * barButtonSuperView, * barButtonPrimaryView, * barButtonSecondaryView;

	EGORefreshTableHeaderView *refreshHeaderView;
	
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	NSMutableArray *AnnotationsClone;
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
	
	BOOL _reloading;
}


@property (nonatomic, retain) NSMutableArray *hotspotArray;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSMutableArray *AnnotationsClone;
@property (nonatomic) BOOL isMapView;
@property (nonatomic) BOOL searchWasActive;
@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (IBAction)locateMe;
- (IBAction)Refresh;
- (CLLocationCoordinate2D) getCurrentCoordinate;
- (IBAction)showList;
-(void)searchTableView:(NSString*)searchText;
-(void)refreshAnnotations:(Hotspot *)hotspot;
- (void)mapZoomToLocation:(CLLocationCoordinate2D)position animated:(BOOL)animated;
-(void)selectAnnotations:(Hotspot *) hotspot;
@end


