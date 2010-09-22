//
//  HotspotInfosViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "HotspotInfosViewController.h"
#import "Favorite.h"
#import "Model.h"
#import "MapViewController.h"
#import "ISFAppDelegate.h"

#define kSectionInfos			0
#define kSectionDirections		1
#define kSectionFavorite		2

#define kRowTagAddress			0
#define kRowTagPhone				1
#define kRowTagEmail				2

#define kActionSheetShowMap	1
#define kActionSheetCallPhone	2
#define kActionSheetSendEmail	3

@implementation HotspotInfosViewController

@synthesize hotspot, currentCoords, exist;


- (void)viewDidLoad {
	
	
	NSString *identifier=hotspot.hotspotId;
	NSPredicate *predicate = identifier
	? [NSPredicate predicateWithFormat:@"identifier == %@", identifier]
	: nil;
	
	id entity = [[Model shared] findFirstObjectForEntityForName:@"Favorite" 
													  predicate:predicate 
													   sortedBy:nil];
	UIBarButtonItem *addfavoriteButton;
	if(entity==nil)
	{
		addfavoriteButton = [[UIBarButtonItem alloc]
										   initWithImage:[UIImage imageNamed:@"favorite-grey2.png"]
										   style:UIBarButtonItemStyleBordered
										   target:self
							 action:@selector(AddDeleteFavorite)];


		self.exist=0;
		
	} else {
		addfavoriteButton = [[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"favorite-color2.png"]
											  style:UIBarButtonItemStyleBordered
											  target:self
							 action:@selector(AddDeleteFavorite)];
		
		self.exist=1;
	}
	
    self.navigationItem.rightBarButtonItem=addfavoriteButton;

	
	
	
	//self.navigationController.topViewController.navigationController.navigationBar.topItem.rightBarButtonItem=addfavoriteButton;
	infos = [[NSMutableArray alloc] init];
	[super viewDidLoad];
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger nbSections = 2;
	if ([hotspot fullAddressOneLine].length > 0) nbSections++;
	return nbSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kSectionDirections) return 1;
	if (section == kSectionFavorite) return 1;
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [hotspot.name sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(280, 80) lineBreakMode:UILineBreakModeWordWrap].height+40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kSectionInfos && indexPath.row == kRowTagAddress) return 60.0f;
	return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section != kSectionInfos) return nil;

	CGSize size = [hotspot.name sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(280, 80) lineBreakMode:UILineBreakModeWordWrap];
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, size.height+40.0f)] autorelease];
//	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, size.height+10)] autorelease];
	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 20, 255, size.height+10)] autorelease];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = hotspot.name;
	nameLabel.font = [UIFont boldSystemFontOfSize:17];
	nameLabel.shadowColor = [UIColor whiteColor];
	nameLabel.shadowOffset = CGSizeMake(0, 1);
	nameLabel.numberOfLines = 3;
	[headerView addSubview:nameLabel];
	
	//UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-down.png"]];
	UIImageView *imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 20,/* size.height+10*/34)] autorelease];

	if ([hotspot status] == kHotspotStatusUnknow) imageView.image = [UIImage imageNamed:@"pin-unknown.png"];
	if ([hotspot status] == kHotspotStatusDown) imageView.image = [UIImage imageNamed:@"pin-down.png"];
	if ([hotspot status] == kHotspotStatusUp) imageView.image = [UIImage imageNamed:@"pin-up.png"];

	
	[headerView addSubview:imageView];

	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *DefaultCellIdentifier = @"DefaultCell";
	static NSString *ButtonCellIdentifier	= @"ButtonCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
	if (cell == nil) {
		if (indexPath.section == kSectionDirections) { 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];
		} else {
		if (indexPath.section == kSectionFavorite) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];
		else cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DefaultCellIdentifier] autorelease];
		}
	}
	
	if (indexPath.section == kSectionDirections) {
		cell.textLabel.text				= NSLocalizedString(@"Directions To Here", @"");
		cell.textLabel.textAlignment	= UITextAlignmentCenter;
		UIImage *img2= [UIImage imageNamed:@"direction.png"];
		cell.imageView.image = img2;
	}else {
	
	if(indexPath.section == kSectionFavorite)	 {
		
		
	/*	NSString *identifier=hotspot.hotspotId;
		NSPredicate *predicate = identifier
		? [NSPredicate predicateWithFormat:@"identifier == %@", identifier]
		: nil;
		
		id entity = [[Model shared] findFirstObjectForEntityForName:@"Favorite" 
														  predicate:predicate 
														   sortedBy:nil];
		
		if(entity==nil)
		{
			cell.textLabel.text				= NSLocalizedString(@"Add to Favorites", @"");
			cell.textLabel.textAlignment	= UITextAlignmentCenter;
			UIImage *img= [UIImage imageNamed:@"favorite-grey.png"];
			cell.imageView.image = img;
			self.exist=0;
			
		} else {
			
			cell.textLabel.text				= NSLocalizedString(@"Remove to Favorites", @"");
			cell.textLabel.textAlignment	= UITextAlignmentCenter;
			UIImage *img= [UIImage imageNamed:@"favorite-color.png"];
			cell.imageView.image = img;
			self.exist=1;
		}*/
		cell.textLabel.text				= NSLocalizedString(@"Show it on the map", @"");
		cell.textLabel.textAlignment	= UITextAlignmentCenter;
		UIImage *img= [UIImage imageNamed:@"showmap.png"];
		cell.imageView.image = img;
		
		
	} else {
		switch (indexPath.row) {
			case kRowTagAddress:
				cell.textLabel.text 			= NSLocalizedString(@"Address", @"");
				cell.detailTextLabel.text	= [hotspot fullAddress];
				cell.detailTextLabel.numberOfLines = 3;
				break;
			case kRowTagPhone:
				cell.textLabel.text 			= NSLocalizedString(@"Phone", @"");
				cell.detailTextLabel.text	= hotspot.contactPhoneNumber;
				break;
			case kRowTagEmail:
				cell.textLabel.text 			= NSLocalizedString(@"Email", @"");
				cell.detailTextLabel.text	= hotspot.contactEmail;
				break;
			default:
				break;
		}
	}
	}

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
		[self showDirections];
	}
	else {
	if (indexPath.section == 2) {
		ISFAppDelegate *appDelegate = (ISFAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSArray *viewControllers =[appDelegate.tabBarController viewControllers];
		UINavigationController *leUINavigationController=(UINavigationController *)[viewControllers objectAtIndex:0];
		MapViewController *laMapViewController=[[leUINavigationController viewControllers] objectAtIndex:0];
		
		[self.navigationController popToRootViewControllerAnimated:NO];
		[appDelegate.tabBarController setSelectedViewController:laMapViewController];
		[appDelegate.tabBarController setSelectedIndex:0];
		CLLocationCoordinate2D coords;
		coords.latitude	= [hotspot.latitude doubleValue];
		coords.longitude	= [hotspot.longitude doubleValue];
		if(!laMapViewController.isMapView)
		{
			[laMapViewController showList];
		}
		[laMapViewController mapZoomToLocation:coords animated:YES];
		[laMapViewController selectAnnotations:hotspot];
		
	}
	 else {
		switch (indexPath.row) {
			case kRowTagAddress:
				[self confirmMap];
				break;
			case kRowTagPhone:
				[self confirmPhone];
				break;
			case kRowTagEmail:
				[self confirmEmail];
				break;
			default:
				break;
		}
	 }
	}

}


- (void)dealloc {
	[infos release];
	[super dealloc];
}


#pragma mark -
#pragma mark Actions

- (void)confirmMap {
	if ([hotspot fullAddressOneLine].length == 0) return;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Open in Google Maps?", @"")
																				delegate:self 
																	cancelButtonTitle:NSLocalizedString(@"No", @"") 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetShowMap;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)showMap {
	if ([hotspot fullAddressOneLine].length == 0) return;
	NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [[hotspot fullAddressOneLine] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[[UIApplication sharedApplication] openURL:myURL];
}

- (void)confirmPhone {
	if (hotspot.contactPhoneNumber == nil) return;
	UIDevice *thisDevice = [UIDevice currentDevice];
	if ([thisDevice.model isEqualToString:@"iPhone"]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Call the phone number?", @"")
																					delegate:self 
																		cancelButtonTitle:NSLocalizedString(@"No", @"") 
																 destructiveButtonTitle:nil 
																		otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.tag = kActionSheetCallPhone;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

- (void)callPhone {
	if (hotspot.contactPhoneNumber == nil) return;
	UIDevice *thisDevice = [UIDevice currentDevice];
	if ([thisDevice.model isEqualToString:@"iPhone"]) {
		NSString *tempPhone = @"";
		NSArray *numArray = [hotspot.contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
		for (NSString *myNum in numArray) {
			tempPhone = [tempPhone stringByAppendingString:myNum];
		}
		NSString *myPhoneUrl = [NSString stringWithFormat:@"tel:%@", tempPhone];
		NSURL *myURL = [NSURL URLWithString:myPhoneUrl];
		[[UIApplication sharedApplication] openURL:myURL];
	}
}


- (void)confirmEmail {
	if (hotspot.contactEmail == nil) return;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Send an email?", @"")
																				delegate:self 
																	cancelButtonTitle:NSLocalizedString(@"No", @"") 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetSendEmail;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)sendEmail {
	if (hotspot.contactEmail == nil) return;
	NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", hotspot.contactEmail]];
	[[UIApplication sharedApplication] openURL:myURL];
}

- (void)showDirections {
	if ([hotspot fullAddressOneLine].length == 0) return;
	NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?daddr==%@&saddr=%f,%f", [[hotspot fullAddressOneLine] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], currentCoords.latitude, currentCoords.longitude]];
	[[UIApplication sharedApplication] openURL:myURL];
}
- (IBAction)AddDeleteFavorite {
	if(!exist)
	{
		
	Favorite *favorite = [[Model shared] insertNewObjectForEntityForName:@"Favorite"];
	favorite.identifier			= hotspot.hotspotId;
	favorite.name				= hotspot.name;
	[favorite setCreatedAt:[NSDate date]];

	
	[[Model shared] save];
		
	UIBarButtonItem *addfavoriteButton;	
	self.exist=1;
		
			addfavoriteButton = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"favorite-color2.png"]
								 style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(AddDeleteFavorite)];
			
		
		
		self.navigationItem.rightBarButtonItem=addfavoriteButton;
		

		
	}else {
		
		NSString *identifier=hotspot.hotspotId;
		NSPredicate *predicate = identifier
		? [NSPredicate predicateWithFormat:@"identifier == %@", identifier]
		: nil;
		
		id entity = [[Model shared] findFirstObjectForEntityForName:@"Favorite" 
														  predicate:predicate 
														   sortedBy:nil];
		Favorite *favorite=entity;
		[[Model shared] deleteObject:favorite];
		[[Model shared] save];
		UIBarButtonItem *addfavoriteButton;
		
		
		
			addfavoriteButton = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"favorite-grey2.png"]
								 style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(AddDeleteFavorite)];
			
			
	
		self.navigationItem.rightBarButtonItem=addfavoriteButton;
		
		
		
		
		
		self.exist=0;
		
	
		
		
	
	}
	
		
	ISFAppDelegate *appDelegate = (ISFAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *viewControllers =[appDelegate.tabBarController viewControllers];
	UINavigationController *leUINavigationController=(UINavigationController *)[viewControllers objectAtIndex:0];
	MapViewController *laMapViewController=[[leUINavigationController viewControllers] objectAtIndex:0];
	[laMapViewController refreshAnnotations:hotspot];
	
}
/*
- (IBAction)closeView {
	[self dismissModalViewControllerAnimated:YES];
}*/


#pragma mark -
#pragma mark Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (actionSheet.tag) {
		case kActionSheetShowMap:
			if (buttonIndex == 0) {
				[self showMap];
			}
			break;
		case kActionSheetCallPhone:
			if (buttonIndex == 0) {
				[self callPhone];
			}
			break;
		case kActionSheetSendEmail:
			if (buttonIndex == 0) {
				[self sendEmail];
			}
			break;
		default:
			break;
	}
}


@end

