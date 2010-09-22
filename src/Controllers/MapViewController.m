//
//  MapViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
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
#import "Favorite.h"
#import "EGORefreshTableHeaderView.h"

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

#define kTransitionDuration 0.75

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

- (void)dataSourceDidFinishLoadingNewData;


@end


@implementation MapViewController

@synthesize hotspotArray,filteredListContent, searchWasActive,AnnotationsClone,isMapView,reloading=_reloading;

- (void)fetchHotspots {

	
	NSString *urlString = @"http://auth.ilesansfil.org/hotspot_status.php?format=XML";
	NSURL *url = [NSURL URLWithString:urlString];
	XMLReader *xmlReader = [[[XMLReader alloc] init] autorelease];
	xmlReader.delegate = self;
	[xmlReader parseXMLFileAtURL:url parseError:nil];
}
- (void)fetchHotspotsLocal {
	
	
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"hotspot.xml"];
	 
	
	 NSURL *url = [NSURL fileURLWithPath:path];
	 
	
	XMLReader *xmlReader = [[[XMLReader alloc] init] autorelease];
	xmlReader.delegate = self;
	[xmlReader parseXMLFileAtURL:url parseError:nil];
}
- (void)XMLReaderDidFinishParsing {

	if (isFirstLaunch == YES) {
		[self mapZoomToLocation:[[map userLocation] coordinate] animated:YES];
		isFirstLaunch = NO;
		//[[LoadingOverlay overlayInstance] hide];
	}
	[[LoadingOverlay overlayInstance] hide];
	[self removeAllAnnotations];
	[self addHotspots];
	
	
	
	hotspotArray=[[NSMutableArray alloc] init];
	[self setHotspotArray:[NSMutableArray arrayWithArray:[Hotspot findAll]]];
	[tableViewHotspot reloadData];	
	
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[hotspotArray count]];
	
	tableViewHotspot.scrollEnabled = YES;

	//NSLog(@"FINI PARSAGE");
}
- (void)XMLReaderDidFailParsing {
}

- (void)viewDidLoad {
   [super viewDidLoad];
	
	searchWasActive=NO;
	
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];

	
	
	

	
	if ([[Hotspot findAll] count] == 0) {
		
		if([self isConnectionAvailable] == NO) {
			
			//ConnectionViewController *connectionview= [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil] autorelease];
			//[self presentModalViewController:connectionview animated:NO];
			
			isFirstLaunch = YES;
			[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
			[self fetchHotspotsLocal];
			
		}else {
			

		isFirstLaunch = YES;
		[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
		[self fetchHotspots];
		
		}
		
	} else {
		//isFirstLaunch = YES;
	//	[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
	//	[self fetchHotspots];
	/*	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchHotspots) object:nil];
		[operationQueue addOperation:operation];
		[operation release];*/
	}

	searchingView.hidden = YES;
	
	locatingLabel.text = NSLocalizedString(@"Locating...", @"");
	
	initialized = NO;
	[searchingView removeFromSuperview];

	// Initialize the current location
	[[map userLocation] setTitle:NSLocalizedString(@"You are here", @"")];

	// Initialize the search location
	searchLocation = [[LocationAnnotation alloc] init];

	// Set the search bar keyboard appearance
	for (UIView *v in addressSearchBar.subviews) {
		if ([v isKindOfClass: [UITextField class]]) {
			((UITextField *)v).keyboardAppearance = UIKeyboardAppearanceAlert;
			break;
		}
	}
	

	
	//initialize bar button views
	barButtonSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 36)];
	barButtonPrimaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 36)];
	UIButton * primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	primaryButton.frame = CGRectMake(0, 0, 37, 36);
	[primaryButton setImage:[UIImage imageNamed:@"btliste.jpg"] forState:UIControlStateNormal];
	//[primaryButton setBackgroundColor:[UIColor greenColor]];
	[primaryButton addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
	[barButtonPrimaryView addSubview:primaryButton];
	

		
	barButtonSecondaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 36)];
	UIButton * secondaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	secondaryButton.frame = CGRectMake(0, 0, 37, 36);
	[secondaryButton setImage:[UIImage imageNamed:@"btmap.jpg"] forState:UIControlStateNormal];
	//[secondaryButton setBackgroundColor:[UIColor redColor]];
	[secondaryButton addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
	[barButtonSecondaryView addSubview:secondaryButton];
	
	
	//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonSuperView] autorelease];
	UIView * barButtonSuperSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 36)];
	barButtonSuperSuperView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	[barButtonSuperSuperView addSubview:barButtonSuperView];
	_navItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonSuperSuperView] autorelease];
	[barButtonSuperSuperView release], barButtonSuperSuperView = nil;
	
	[barButtonSuperView addSubview:barButtonPrimaryView];
	
	
	hotspotArray=[[NSMutableArray alloc] init];
	[self setHotspotArray:[NSMutableArray arrayWithArray:[Hotspot findAll]]];
	
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableViewHotspot.bounds.size.height, 320.0f, tableViewHotspot.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[tableViewHotspot addSubview:refreshHeaderView];
		tableViewHotspot.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	[tableViewHotspot reloadData];	
	
	
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[hotspotArray count]];
		
	
	self.navigationController.navigationBarHidden = YES;
	
	
	if([self isConnectionAvailable] == NO) {
		//map.hidden=true;
		connectionView.hidden=true;
		[map removeFromSuperview];
		[principalView addSubview:tableViewHotspot];
		[barButtonSuperView addSubview:barButtonSecondaryView];
		isMapView=NO;
		
		
	} else {
		
		connectionView.hidden=true;
		isMapView=YES;
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationItem.title = NSLocalizedString(@"Hotspots", @"");
	self.navigationController.navigationBarHidden = YES;
	
	
	/*if([self isConnectionAvailable] == NO) {
		ConnectionViewController *connectionView= [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil] autorelease];
		[self presentModalViewController:connectionView animated:NO];
	}*/
	
/*	if([self isConnectionAvailable] == NO) {
		//map.hidden=true;
		connectionView.hidden=true;
		[map removeFromSuperview];
		[principalView addSubview:tableViewHotspot];
		[barButtonSuperView addSubview:barButtonSecondaryView];
		isMapView=NO;
		
		
	} else {
		
		connectionView.hidden=true;
		isMapView=YES;
	}*/
	needsZoomOut = YES;
	

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	//[self removeAllAnnotations];
	
	//NSLog(@"tototo");
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[map release];
//	[gMapsAPI release];

	[tableViewHotspot release];
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
	[AnnotationsClone release];
	//NSLog(@"FINI suppr annotation");
}

- (void)addHotspots {
	AnnotationsClone=[[NSMutableArray alloc] init];
	
	for (Hotspot *hotspot in [Hotspot findAll]) {
		LocationAnnotation *annotation = [[[LocationAnnotation alloc] init] autorelease];
		annotation.title = hotspot.name;
		annotation.subtitle = [hotspot fullAddressOneLine];
		CLLocationCoordinate2D coords;
		coords.latitude	= [hotspot.latitude doubleValue];
		coords.longitude	= [hotspot.longitude doubleValue];
		annotation.coordinate = coords;
		annotation.hotspot = hotspot;

		[AnnotationsClone addObject:annotation];
		[map addAnnotation:(LocationAnnotation *)annotation];
				
	
	}
	//NSLog(@"FINI ajout annotation");
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
-(void)refreshAnnotations:(Hotspot *)hotspot {

	NSInteger i=0;
	while(i<[AnnotationsClone count]) {
			
		if([[[[AnnotationsClone objectAtIndex:i]hotspot]hotspotId] isEqualToString:hotspot.hotspotId])
		{
		
			LocationAnnotation *annotation2 = [[[LocationAnnotation alloc] init] autorelease];
			
			annotation2=[[map annotations] objectAtIndex:i+1];

			[map removeAnnotation:[[map annotations] objectAtIndex:i+1]];
			[AnnotationsClone removeObjectAtIndex:i];
			[map addAnnotation:annotation2];
			[AnnotationsClone addObject:annotation2];
			[tableViewHotspot reloadData];
			
			return;
		}
	
		
		i++;
		
	}
	
	
	
}
-(void)selectAnnotations:(Hotspot *) hotspot {
	NSInteger i=0;
	while(i<[AnnotationsClone count]) {
		
		if([[[[AnnotationsClone objectAtIndex:i]hotspot]hotspotId] isEqualToString:hotspot.hotspotId])
		{
			
			[map selectAnnotation:[[map annotations] objectAtIndex:i+1] animated:YES];
			return;
		}
		
		
		i++;
		
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
	
	NSMutableArray *FavoritesArray=[[NSMutableArray alloc] init];
	FavoritesArray=[NSMutableArray arrayWithArray:[Favorite findAll]];
	NSInteger i=0;
	BOOL isFavorite=FALSE;
	while(i<[FavoritesArray count])
	{
		
		if([[[FavoritesArray objectAtIndex:i] identifier] isEqualToString:((LocationAnnotation *)annotation).hotspot.hotspotId])
			   //[[FavoritesArray objectAtIndex:i] identifier]==((LocationAnnotation *)annotation).hotspot.hotspotId)
			{
				i=[FavoritesArray count];
				isFavorite=TRUE;
			}
		i++;
	}

	if ((LocationAnnotation *)annotation == searchLocation) mkav.image = [UIImage imageNamed:@"pin-search.png"];
	else {
		mkav.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusUnknow) mkav.image = [UIImage imageNamed:@"pin-unknown.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusDown && isFavorite==FALSE) mkav.image = [UIImage imageNamed:@"pin-down.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusUp && isFavorite==FALSE) mkav.image = [UIImage imageNamed:@"pin-up.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusDown && isFavorite==TRUE) mkav.image = [UIImage imageNamed:@"pin-down-fav.png"];
		if ([((LocationAnnotation *)annotation).hotspot status] == kHotspotStatusUp && isFavorite==TRUE) mkav.image = [UIImage imageNamed:@"pin-up-fav.png"];
	}

	return mkav;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	//Action du bouton info des annotations
	HotspotInfosViewController *infosController = [[[HotspotInfosViewController alloc] init] autorelease];
	infosController.hotspot = ((LocationAnnotation *)(view.annotation)).hotspot;
	infosController.currentCoords = mapView.userLocation.coordinate;
	
	[self.navigationController pushViewController:infosController animated:YES];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
		
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	if(initialized == NO && map.region.span.latitudeDelta < MAX_SPAN_DELTA) {
		[self addHotspots];
		
		//A VERIFIER COMMENTER ADDHOTSPOTS
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
- (IBAction)Refresh {

	[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
	[self fetchHotspots];
	[tableViewHotspot reloadData];
	/*[self removeAllAnnotations];
	
	[self addHotspots];*/
	
}
	

-(CLLocationCoordinate2D) getCurrentCoordinate {
	CLLocationCoordinate2D coordinate= [[map userLocation] coordinate];
	
	return coordinate;
	
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	
	[addressSearchBar setShowsCancelButton:YES animated:YES];
	//if(!map.hidden)
	if(isMapView == YES)
	{
	[self showList];
	}
	//si on est sur la map et que l'on appuis sur le bouton recherche on affiche la liste
	
}


#pragma mark -
#pragma mark Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchWasActive = NO;
	[addressSearchBar setText:@""];
	[tableViewHotspot reloadData];
	[addressSearchBar setShowsCancelButton:NO animated:YES];
	[addressSearchBar resignFirstResponder];
	
	//quand on clique sur le bouton cancel on annule la recherche resignFirstResponder permet d'enlever le clavier
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[addressSearchBar resignFirstResponder];
	[addressSearchBar setShowsCancelButton:NO animated:YES];
	
	//on enleve le clavier et le bouton cancel pour permettre de mieux voir les resultat obtenu
}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	//Remove all objects first.
	[self.filteredListContent removeAllObjects];
	
	if([addressSearchBar.text length] > 0) {
		
	
		searchWasActive = YES;
	
	
		[self searchTableView:addressSearchBar.text];
		
		//si la barre de recherche est rempli on dit que la recherche est active et on cherche les resultat correspondant
	}
	else {
		
		searchWasActive = NO;
		//sinon lorsque on supprimer les caractères de la recherche on dit que la recherche est inactive pour afficher la liste complete
	}

	[tableViewHotspot reloadData];
}


-(void)searchTableView:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	for (Hotspot *hotspot in hotspotArray)
	{
		NSRange titleResultsRange = [hotspot.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
		NSRange titleResultsRange2 = [hotspot.streetAddress rangeOfString:searchText options:NSCaseInsensitiveSearch];
		NSRange titleResultsRange3 = [hotspot.postalCode rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0 | titleResultsRange2.length > 0 | titleResultsRange3.length > 0)
			[self.filteredListContent addObject:hotspot];
	}
	
	
	
}


- (IBAction)showList {
	
	

	[UIView beginAnimations:@"BarButtonViewAnimation" context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	
	[UIView setAnimationTransition:([barButtonPrimaryView superview] ?
									UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft)
						   forView:barButtonSuperView cache:YES];
	
	//Flip pour le bouton map / liste à coté de la barre de recherce
	
	if (isMapView == YES) 
	{
		[barButtonPrimaryView removeFromSuperview];
		[barButtonSuperView addSubview:barButtonSecondaryView];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:principalView cache:YES];
		[map removeFromSuperview];
		[principalView addSubview:tableViewHotspot];
		[UIView commitAnimations];
		isMapView = NO;
		connectionView.hidden=true;
		
		//si la map est presentement affiché quand on appuis sur le bouton on change le bouton , la map s'enlève pour mette la liste à la place
		
	} else {
		
		
		
		[barButtonPrimaryView removeFromSuperview];
		[barButtonSuperView addSubview:barButtonPrimaryView];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:principalView cache:YES];
		[tableViewHotspot removeFromSuperview];
		if([self isConnectionAvailable] == NO) {
			[principalView addSubview:connectionView];
			[alertMain setText:NSLocalizedString(@"Cannot connect to the Internet", @"")];
			[alertMessage setText:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network to view the map.", @"")];
			connectionView.hidden=false;
			
			//si on est pas sur la map (donc la liste est affiché) quand on appuis sur le bouton dans le cas ou il n'y a pas de connection internet on enleve la liste et on met la vue qui explique qu'il n'y a pas de connection
		} else {
			[principalView addSubview:map];
			[principalView addSubview:BtLocateme];
			[principalView addSubview:BtRefresh];
			//si on est pas sur la map (donc la liste est affiché) quand on appuis sur le bouton dans le cas ou il n'y a une connection internet on enleve la map (ou la page d'explication hors ligne) et on met la liste
		}
		
		[UIView commitAnimations];
		isMapView = YES;
		[addressSearchBar setText:@""];
		
		[addressSearchBar resignFirstResponder];
		searchWasActive=NO;
		[addressSearchBar setShowsCancelButton:NO animated:YES];
		//on vide la barre d'adresse on dit que la barre de recherche n'est pas active et on enleve le bouton annuler la recherche
		[tableViewHotspot reloadData];
	}
	
	[UIView commitAnimations];
	
	
}

#pragma mark -
#pragma mark Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(searchWasActive==YES)
	{
        return [self.filteredListContent count];
    } else {
        return [hotspotArray count];
		
    }
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 60.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	
	static NSString *CellIdentifier = @"identifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
	}
	Hotspot *hotspot = nil;
	
	if(searchWasActive==YES)
	{
        hotspot = (Hotspot *)[self.filteredListContent objectAtIndex:indexPath.row];
		
    } else {
        hotspot = (Hotspot *)[hotspotArray objectAtIndex:indexPath.row];
    }
	
		
	NSString *address=[[hotspot civicNumber] stringByAppendingString:@" "];
	address=[address stringByAppendingString:[hotspot streetAddress]];
	address=[address stringByAppendingString:@" "];
	cell.detailTextLabel.text=[address stringByAppendingString:[hotspot postalCode]];
	
	cell.textLabel.text = [hotspot name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	UIImage *img=[[UIImage alloc] init];
	
	NSMutableArray *FavoritesArray=[[NSMutableArray alloc] init];
	FavoritesArray=[NSMutableArray arrayWithArray:[Favorite findAll]];
	NSInteger i=0;
	BOOL isFavorite=FALSE;
	while(i<[FavoritesArray count])
	{
		
		if([[[FavoritesArray objectAtIndex:i] identifier] isEqualToString:hotspot.hotspotId])
			//[[FavoritesArray objectAtIndex:i] identifier]==((LocationAnnotation *)annotation).hotspot.hotspotId)
		{
			i=[FavoritesArray count];
			isFavorite=TRUE;
		}
		i++;
	}
	//NSLog(@"Is FAVORITE: %@", isFavorite ? @"YES" : @"NO");
		
	if ([hotspot status] == kHotspotStatusUnknow) img = [UIImage imageNamed:@"pin-unknown.png"];
	if ([hotspot status] == kHotspotStatusDown && isFavorite==FALSE) img = [UIImage imageNamed:@"pin-down.png"];
	if ([hotspot status] == kHotspotStatusUp && isFavorite==FALSE) img = [UIImage imageNamed:@"pin-up.png"];
	if ([hotspot status] == kHotspotStatusDown && isFavorite==TRUE) img = [UIImage imageNamed:@"pin-down-fav.png"];
	if ([hotspot status] == kHotspotStatusUp && isFavorite==TRUE) img = [UIImage imageNamed:@"pin-up-fav.png"];
    cell.imageView.image = img;
	cell.textLabel.textAlignment	= UITextAlignmentCenter;
	
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
		
	
	Hotspot *hotspot = nil;

	if(searchWasActive==YES)
	{
        hotspot =  (Hotspot *)[self.filteredListContent objectAtIndex:indexPath.row];
		[addressSearchBar resignFirstResponder];
	
    } else {
        hotspot = (Hotspot *)[hotspotArray objectAtIndex:indexPath.row];
    }
	
		HotspotInfosViewController *infosController = [[[HotspotInfosViewController alloc] init] autorelease];
		infosController.hotspot = hotspot;
		infosController.currentCoords =[self getCurrentCoordinate];
		[self.navigationController pushViewController:infosController animated:YES];
	
	
		
	
}




- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
	[self fetchHotspots];
	[tableViewHotspot reloadData];
	//[self removeAllAnnotations];
	
	//[self addHotspots];
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:13.0];
}


- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		tableViewHotspot.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData {
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[tableViewHotspot setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}



@end