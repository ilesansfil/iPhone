//
//  MapViewController.m
//  Ile sans fil
//
//  Created by Oli on 11/06/09.
//  Copyright 2009 Kolt Production. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "googleMapsAPI.h"
#import "Hotspot.h"
#import "HotspotInfosViewController.h"
#import "ISFAppDelegate.h"
#import "LoadingOverlay.h"
#import "ConnectionViewController.h"


#define ZOOM_DEFAULT 1000		// 1000 meters
#define ZOOM_INCREMENT 0.01
#define MAX_SPAN_DELTA 0.4
#define DELTA_UPDATE 0.1

#define MAX_LOCATIONS 280
#define NB_SHOW_BANKS 3

#define BOUND_X_MIN -10
#define BOUND_X_MAX 330
#define BOUND_Y_MIN 0
#define BOUND_Y_MAX 400


@interface MapViewController (Internal)

- (BOOL)isConnectionAvailable;

- (void)displaySearchingView;
- (void)removeSearchingView;
- (void)displayNoHotspotView;
- (void)removeNoHotspotView;

- (void)removeAllAnnotations;
- (void)addHotspots;
- (void)checkLocationsInView;

- (void)updateMapLocations;
- (void)mapZoomOut;
- (void)mapZoomToLocation:(CLLocationCoordinate2D)position animated:(BOOL)animated;

- (void)searchAddress;
@end


@implementation MapViewController


- (void)fetchHotspots {
	NSString *urlString = @"http://auth.ilesansfil.org/hotspot_status.php?format=XML";
	NSURL *url = [NSURL URLWithString:urlString];
	XMLReader *xmlReader = [[[XMLReader alloc] init] autorelease];
	xmlReader.delegate = self;
	[xmlReader parseXMLFileAtURL:url parseError:nil];
}

- (void)XMLReaderDidFinishParsing {
	if (isFirstLaunch == YES) {
		[self mapZoomToLocation:[[map userLocation] coordinate] animated:YES];
		isFirstLaunch = NO;
		[[LoadingOverlay overlayInstance] hide];
	}
	[self removeAllAnnotations];
//	[self performSelectorOnMainThread:@selector(addHotspots) withObject:nil waitUntilDone:NO];
	[self addHotspots];
}
- (void)XMLReaderDidFailParsing {
}

- (void)viewDidLoad {
   [super viewDidLoad];

	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];

//	[self fetchHotspots];
	if ([[Hotspot findAll] count] == 0) {
		isFirstLaunch = YES;
		[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
		[self fetchHotspots];
	}
	else {
		NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchHotspots) object:nil];
		[operationQueue addOperation:operation];
		[operation release];
	}

	searchingView.hidden = YES;
	
	locatingLabel.text = NSLocalizedString(@"Locating...", @"");
	
	initialized = NO;
	[searchingView removeFromSuperview];

	// Initialize the current location
	[[map userLocation] setTitle:NSLocalizedString(@"You are here", @"")];

	// Initialize the search location
	searchLocation = [[LocationAnnotation alloc] init];

	// Initialize the Google Maps API
	gMapsAPI = [[googleMapsAPI alloc] init];
	gMapsAPI.delegate = self;

	// Set the search bar keyboard appearance
	for (UIView *v in addressSearchBar.subviews) {
		if ([v isKindOfClass: [UITextField class]]) {
			((UITextField *)v).keyboardAppearance = UIKeyboardAppearanceAlert;
			break;
		}
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if([self isConnectionAvailable] == NO) {
		ConnectionViewController *connectionView= [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil] autorelease];
		[self presentModalViewController:connectionView animated:NO];
	}
	
	needsZoomOut = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	[self removeAllAnnotations];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[map release];
	[gMapsAPI release];

	[operationQueue release];
	[noHotspotView release];
	[searchingView release];
	[super dealloc];
}


#pragma mark -
#pragma mark Internet Connection

- (BOOL)isConnectionAvailable {
	static BOOL checkNetwork = YES;
	static BOOL available = NO;
	if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
		checkNetwork = NO;
		
		Boolean success;    
		const char *host_name = "google.com";
		
		SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
		SCNetworkReachabilityFlags flags;
		success = SCNetworkReachabilityGetFlags(reachability, &flags);
		available = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
		CFRelease(reachability);
	}
	return available;
}


#pragma mark -
#pragma mark Notifications Views

- (void)displaySearchingView {
	searchingLocation = YES;
//	[self.view addSubview:searchingView];
}
- (void)removeSearchingView {
	[searchingView removeFromSuperview];
	if(searchingLocation == YES) {
		searchingLocation = NO;
		[map selectAnnotation:searchLocation animated:YES];
	}
	if(locatingMe == YES) {
		locatingMe = NO;
		[map selectAnnotation:[map userLocation] animated:YES];
	}
}


- (void)displayNoHotspotView {
	if(initialized == NO || noHotspotView != nil || updatingLocations == YES) return;
	noHotspotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
	UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
	background.image = [UIImage imageNamed:@"alert_back-red.png"];
	[noHotspotView addSubview:background];
	[background release];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:13];
	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
	label.shadowOffset = CGSizeMake(0, -1);
	label.textAlignment = UITextAlignmentCenter;
	label.text = [NSString stringWithString:NSLocalizedString(@"There are no location in the area", @"")];
	[noHotspotView addSubview:label];
	[label release];
	[map addSubview:noHotspotView];
}
- (void)removeNoHotspotView {
	if(noHotspotView == nil) return;
	[noHotspotView removeFromSuperview];
	[noHotspotView release];
	noHotspotView = nil;
}

#pragma mark -
#pragma mark Annotations

- (void)removeAllAnnotations {
	NSArray *annotations = [[NSArray alloc] initWithArray:map.annotations];
	NSEnumerator *enumerator = [annotations objectEnumerator];
	LocationAnnotation *location;
	while (location = [enumerator nextObject]) {
		if(location == (LocationAnnotation *)[map userLocation]) {
			currentLocationInMap = YES;
			continue;
		}
		if(location == searchLocation) {
			continue;
		}
		[map removeAnnotation:location];
	}
	[annotations release];
}

- (void)addHotspots {
	for (Hotspot *hotspot in [Hotspot findAll]) {
		LocationAnnotation *annotation = [[[LocationAnnotation alloc] init] autorelease];
		annotation.title = hotspot.name;
		annotation.subtitle = [hotspot fullAddressOneLine];
		CLLocationCoordinate2D coords;
		coords.latitude	= [hotspot.latitude doubleValue];
		coords.longitude	= [hotspot.longitude doubleValue];
		annotation.coordinate = coords;
		annotation.hotspot = hotspot;
		[map addAnnotation:annotation];
	}
}

- (void)checkLocationsInView {
	locationInView = NO;
	for (LocationAnnotation *annotation in [map annotations]) {
		if (annotation == (LocationAnnotation *)[map userLocation] || annotation == searchLocation) continue;
		CLLocationCoordinate2D coords = annotation.coordinate;
		CGPoint point = [map convertCoordinate:coords toPointToView:map];
		if(point.x > BOUND_X_MIN && point.x < BOUND_X_MAX && point.y > BOUND_Y_MIN && point.y < BOUND_Y_MAX) {
			locationInView = YES;
			[self removeNoHotspotView];
			return;
		}
	}
}


#pragma mark -
#pragma mark Map Kit

// Zoom out by ZOOM_INCREMENT
- (void)mapZoomOut {
	MKCoordinateRegion region = map.region;
	if(region.span.latitudeDelta >= MAX_SPAN_DELTA || region.span.longitudeDelta >= MAX_SPAN_DELTA) {
		needsZoomOut = NO;
		return;
	}
	region.span.latitudeDelta += ZOOM_INCREMENT;
	region.span.longitudeDelta += ZOOM_INCREMENT;
	[map setRegion:region animated:YES];
}

// Zoom to a specified location
- (void)mapZoomToLocation:(CLLocationCoordinate2D)position animated:(BOOL)animated {
	if (position.latitude == -180 || position.longitude == -180) return;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(position, ZOOM_DEFAULT, ZOOM_DEFAULT);
	[map setRegion:region animated:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (isFirstLaunch) return nil;
	if(annotation == [mapView userLocation]) {
		if(initialized == NO) {
			[self mapZoomToLocation:[[map userLocation] coordinate] animated:YES];
		}
		return nil;
	}

	static NSString *annotationIdentifier = @"DefaultPinID";
	MKAnnotationView *mkav = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];

	if (mkav == nil) {
		 mkav = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
	} else {
		 mkav.annotation = annotation;
	}
	
	mkav.canShowCallout = TRUE;
	
	if ((LocationAnnotation *)annotation == searchLocation) mkav.image = [UIImage imageNamed:@"pin-search.png"];
	else {
		mkav.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusUnknow) mkav.image = [UIImage imageNamed:@"pin-unknown.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusDown) mkav.image = [UIImage imageNamed:@"pin-down.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusUp) mkav.image = [UIImage imageNamed:@"pin-up.png"];
	}

	return mkav;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	HotspotInfosViewController *infosController = [[[HotspotInfosViewController alloc] initWithNibName:@"HotspotInfosViewController" bundle:nil] autorelease];
	infosController.hotspot = ((LocationAnnotation *)(view.annotation)).hotspot;
	infosController.currentCoords = mapView.userLocation.coordinate;
	[self presentModalViewController:infosController animated:YES];
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	if(initialized == NO && map.region.span.latitudeDelta < MAX_SPAN_DELTA) {
		[self addHotspots];
		initialized = YES;
	}
	if(initialized == NO || loadingMap == YES) return;

	if(searchingLocation == NO) {
		[self checkLocationsInView];
		if (locationInView == NO) [self mapZoomOut];
	}

	// Is there any location in the area
	if(locationInView == NO && (mapView.region.span.latitudeDelta >= MAX_SPAN_DELTA || mapView.region.span.longitudeDelta >= MAX_SPAN_DELTA)) {
		[self displayNoHotspotView];
	}
	else [self removeNoHotspotView];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
	loadingMap = YES;
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	loadingMap = NO;
	if(searchingLocation == YES) {
		[self removeSearchingView];
		[self mapZoomToLocation:searchLocation.coordinate animated:YES];
	}
	else {
		[self checkLocationsInView];
		if (locationInView == NO) [self mapZoomOut];
	}

	[map showsUserLocation];
	
}


#pragma mark -
#pragma mark Location

- (IBAction)locateMe {
	needsZoomOut = YES;
	locatingMe = YES;
	[self mapZoomToLocation:[[map userLocation] coordinate] animated:NO];
	[map selectAnnotation:[map userLocation] animated:YES];
}


#pragma mark -
#pragma mark Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchingLocation = NO;
	searchLocation.title = @"";
	if (searchLocation != nil) [map removeAnnotation:searchLocation];
	[self removeSearchingView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	searchLocation.title = [NSString stringWithString:searchBar.text];
	[searchBar resignFirstResponder];
	[self searchAddress];
}

- (void)searchAddress {
	if(addressSearchBar.text == nil) return;
	[self displaySearchingView];
	addressSearchBar.text = [NSString stringWithFormat:@"%@, Montreal, QC, Canada", addressSearchBar.text];
	
	// Send an asynchronous request to the Google Maps API
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:gMapsAPI selector:@selector(getCoordFromAddress:) object:addressSearchBar.text];
	[operationQueue addOperation:operation];
	[operation release];
}

#pragma mark -
#pragma mark Google Maps API

- (void)googleMapsAPIDidFindCoordinates:(CLLocationCoordinate2D)coordinates {
	if(searchLocation.coordinate.latitude == coordinates.latitude && searchLocation.coordinate.longitude == coordinates.longitude) [self removeSearchingView];
	else searchLocation.coordinate = coordinates;
	[map addAnnotation:searchLocation];
	[map setCenterCoordinate:coordinates animated:YES];
}
- (void)googleMapsAPIDidFailWithMessage:(NSString *)message {
	searchLocation.title = @"";
	[self removeSearchingView];
}



@end