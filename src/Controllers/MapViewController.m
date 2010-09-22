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
@end


@implementation MapViewController

@synthesize hotspotArray,filteredListContent, searchWasActive;

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
	[self addHotspots];
	
	
	hotspotArray=[[NSMutableArray alloc] init];
	[self setHotspotArray:[NSMutableArray arrayWithArray:[Hotspot findAll]]];
	[tableViewHotspot reloadData];	
	
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[hotspotArray count]];
	
	tableViewHotspot.scrollEnabled = YES;

	
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
			
			ConnectionViewController *connectionview= [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil] autorelease];
			[self presentModalViewController:connectionview animated:NO];
			
		}else {
			

		isFirstLaunch = YES;
		[[LoadingOverlay overlayInstance] showMessage:NSLocalizedString(@"Loading...", @"") inViewController:[self parentViewController]];
		[self fetchHotspots];
		
		}
		
	} else {
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

	// Set the search bar keyboard appearance
	for (UIView *v in addressSearchBar.subviews) {
		if ([v isKindOfClass: [UITextField class]]) {
			((UITextField *)v).keyboardAppearance = UIKeyboardAppearanceAlert;
			break;
		}
	}
	

	/*
	UIBarButtonItem *showListButton = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"tab-list2.png"]
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(showList)];
	
	[_navItem setLeftBarButtonItem:showListButton];
	*/
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
	
	[self removeAllAnnotations];
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
		
		if (titleResultsRange.length > 0 | titleResultsRange2.length > 0)
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
	cell.detailTextLabel.text=[address stringByAppendingString:[hotspot streetAddress]];

	cell.textLabel.text = [hotspot name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		
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



@end