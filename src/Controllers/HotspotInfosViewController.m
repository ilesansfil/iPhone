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
#import "FBConnect.h"
#import "UserRequestResult.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define kSectionInfos			0
#define kSectionDirections		1
#define kSectionFavorite		2

#define kRowTagAddress			0
#define kRowTagPhone				1
#define kRowTagEmail				2

#define kActionSheetShowMap	1
#define kActionSheetCallPhone	2
#define kActionSheetSendEmail	3



// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
static NSString* kAppId = @"154563301232449";




@implementation HotspotInfosViewController

@synthesize hotspot, currentCoords, exist;
@synthesize label = _label;

- (void)viewDidLoad {
	
	twitterviewcontroller = [[TwitterViewController alloc] initWithNibName:@"TwitterViewController" bundle:[NSBundle mainBundle]];
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
	
	
	_facebook = [[self restore] retain];
	if (_facebook == nil) {
		_facebook = [[Facebook alloc] init];
		_fbButton.isLoggedIn = NO;
		NSLog(@"PAS LOGUER");
	} else {
		_fbButton.isLoggedIn = YES;
		//[self fbDidLogin];
		NSLog(@"restore LOGUé");
	}

	
	
	/*_facebook = [[Facebook alloc] init];
	[self.label setText:@"Please log in"];
	_getUserInfoButton.hidden    = YES;
	_getPublicInfoButton.hidden   = YES;
	_publishButton.hidden        = YES;
	_uploadPhotoButton.hidden    = YES;
	_fbButton.isLoggedIn   = NO;
	[_fbButton updateImage];
	*/
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
	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 20, 200, size.height+10)] autorelease];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = hotspot.name;
	nameLabel.font = [UIFont boldSystemFontOfSize:17];
	nameLabel.shadowColor = [UIColor whiteColor];
	nameLabel.shadowOffset = CGSizeMake(0, 1);
	nameLabel.numberOfLines = 3;
	[headerView addSubview:nameLabel];
	
	UIButton *bt_share = [[UIButton alloc] initWithFrame:CGRectMake(235, 5, 50, size.height+40.0f)];
	[bt_share setImage:[UIImage imageNamed:@"logo_twitter.png"] forState:UIControlStateNormal];
	//bt_share.showsTouchWhenHighlighted = NO;
	//bt_share.adjustsImageWhenHighlighted = NO;
	[bt_share addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:bt_share];
	//bt_share.hidden=true;
	
	_fbButton = [[FBLoginButton alloc] initWithFrame:CGRectMake(275, 5, 50, size.height+40.0f)];
	[_fbButton setImage:[UIImage imageNamed:@"logo_facebook.png"] forState:UIControlStateNormal];
	//bt_share.showsTouchWhenHighlighted = NO;
	//bt_share.adjustsImageWhenHighlighted = NO;
	[_fbButton addTarget:self action:@selector(fbButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_fbButton];
	 // [_fbButton updateImage];
	
	UIImageView *imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 20,/* size.height+10*/34)] autorelease];

	if ([hotspot status] == kHotspotStatusUnknow) imageView.image = [UIImage imageNamed:@"pin-unknown.png"];
	if ([hotspot status] == kHotspotStatusDown) imageView.image = [UIImage imageNamed:@"pin-down.png"];
	if ([hotspot status] == kHotspotStatusUp) imageView.image = [UIImage imageNamed:@"pin-up.png"];

	
	[headerView addSubview:imageView];

	return headerView;
}
- (void)buttonPressed:(UIButton *)sender {
	
	if([self isConnectionAvailable])
	{
	NSLog(@"BT PRESSED",@"");
	[self.navigationController pushViewController:twitterviewcontroller animated:YES];
	
	//si + 60 mettre ... , + nom twitter de tous les conferenciers
	NSString *texte=[[NSString alloc] init];
	
	
	texte=[[NSLocalizedString(@"@ ",@"") stringByAppendingString:hotspot.name] stringByAppendingString:@" #isf"];
	
	[twitterviewcontroller setmessage:texte];
	}else {
		[self alertNotice:@"" withMSG:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network.",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
	}

	
	
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
	[_label release];
	[_fbButton release];
	[_getUserInfoButton release];
	[_getPublicInfoButton release];
	[_publishButton release];
	[_uploadPhotoButton release];
	[_facebook release];
	[_permissions release];

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




//FACEBOOK 

/**
 * initialization 
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_permissions =  [[NSArray arrayWithObjects: 
						  @"read_stream", @"offline_access",nil] retain];
	}
	
	return self;
}


/**
 * Example of facebook login and permission request
 */
- (void) login {
	[_facebook authorize:kAppId permissions:_permissions delegate:self];
	 
}

/**
 * Example of facebook logout
 */
- (void) logout {
	[_facebook logout:self]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// IBAction

/**
 * Login/out button click
 */
- (IBAction) fbButtonClick: (id) sender {

	if([self isConnectionAvailable])
	{
		if (_fbButton.isLoggedIn) {
		
			SBJSON *jsonWriter = [[SBJSON new] autorelease];
		
			NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
															   @"Always Running",@"text",@"http://ilesansfil.org/",@"href", nil], nil];
		
/*		NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
		NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
									@"Ile Sans Fil", @"name",
									[@"shared from ISF hotspot of : " stringByAppendingString:hotspot.name], @"caption",
									[[[@" " stringByAppendingString:hotspot.civicNumber] stringByAppendingString:@" "] stringByAppendingString:hotspot.streetAddress], @"description",
									@"http://ilesansfil.org/", @"href", nil];*/
		
			NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
			NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
									[[NSLocalizedString(@"Connected @ ",@"") stringByAppendingString:hotspot.name] stringByAppendingString:NSLocalizedString(@" • An Ile sans fil's hotspot",@"")], @"name",
									[[[[[@"" stringByAppendingString:hotspot.civicNumber] stringByAppendingString:@" "] stringByAppendingString:hotspot.streetAddress] stringByAppendingString:@", "] stringByAppendingString:hotspot.postalCode], @"caption",
									NSLocalizedString(@"My wireless community in Montreal",@""), @"description",
									@"http://ilesansfil.org/", @"href", nil];
		
		
			NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
			NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   kAppId, @"api_key",
									   @"Share on Facebook",  @"user_message_prompt",
									   actionLinksStr, @"action_links",
									   attachmentStr, @"attachment",
									   nil];
		
		
			[_facebook dialog: @"stream.publish"
				andParams: params
			  andDelegate:self];
		//[self logout];
		} else {
			[self login];
		
		}
	}else {
		[self alertNotice:@"" withMSG:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network.",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
	}

	
}

/**
 * Example of graph API CAll
 *
 * This lets you make a Graph API Call to get the information of current logged in user.
 */
- (void) getUsername {
	[_facebook requestWithGraphPath:@"me" andDelegate:self];
}


/**
 * Example of REST API CAll
 *
 * This lets you make a REST API Call to get a user's public information with FQL.
 */
- (IBAction) getPublicInfo: (id)sender {
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"SELECT uid,name FROM user WHERE uid=4", @"query",
									nil];
	[_facebook requestWithMethodName: @"fql.query" 
						   andParams: params
					   andHttpMethod: @"POST" 
						 andDelegate: self]; 
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


/**
 * Callback for facebook login
 */ 
- (void)userRequestCompleteWithUid:(NSString *)uid {
	_uid = uid;
	[self setSessionWithFacebook:_facebook andUid:_uid];
	//set user id
	[self save];
	//save of user id, token
	[self getUsername];
	NSLog(@"uid SETTER %@",uid);
}
-(void)userRequestFailed {
	NSLog(@"user request failed !!");	
}
-(void) fbDidLogin {
	[self.label setText:@"logged in"];
	_getUserInfoButton.hidden    = NO;
	_getPublicInfoButton.hidden   = NO;
	_publishButton.hidden        = NO;
	_uploadPhotoButton.hidden    = NO;
	_fbButton.isLoggedIn         = YES;
	
	UserRequestResult *userRequestResult = [[[[UserRequestResult alloc] initializeWithDelegate:self] autorelease] retain];
	[_facebook requestWithGraphPath:@"me" andDelegate:userRequestResult];
	

	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
														   @"Always Running",@"text",@"http://ilesansfil.org/",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								[[NSLocalizedString(@"Connected @ ",@"") stringByAppendingString:hotspot.name] stringByAppendingString:NSLocalizedString(@" • An Ile sans fil's hotspot",@"")], @"name",
								[[[[[@"" stringByAppendingString:hotspot.civicNumber] stringByAppendingString:@" "] stringByAppendingString:hotspot.streetAddress] stringByAppendingString:@", "] stringByAppendingString:hotspot.postalCode], @"caption",
								NSLocalizedString(@"My wireless community in Montreal",@""), @"description",
								@"http://ilesansfil.org/", @"href", nil];
	
	
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kAppId, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	
	
	[_facebook dialog: @"stream.publish"
			andParams: params
		  andDelegate:self];
	
	//[_fbButton updateImage];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout {
	[self.label setText:@"Please log in"];
	_getUserInfoButton.hidden    = YES;
	_getPublicInfoButton.hidden   = YES;
	_publishButton.hidden        = YES;
	_uploadPhotoButton.hidden = YES;
	_fbButton.isLoggedIn         = NO;
	[_fbButton updateImage];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	[self.label setText:[error localizedDescription]];
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0]; 
	}
	if ([result objectForKey:@"owner"]) {
		[self.label setText:@"Photo upload Success"];
	} else {
		[self.label setText:[result objectForKey:@"name"]];
		NSLog(@"name %@",[result objectForKey:@"name"]);
	}
};

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/** 
 * Called when a UIServer Dialog successfully return
 */
- (void)dialogDidComplete:(FBDialog*)dialog{
	[self.label setText:@"publish successfully"];
}



- (void) save {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ((_uid != (NSString *) [NSNull null]) && (_uid.length > 0)) {
		[defaults setObject:_uid forKey:@"FBUserId"];
			NSLog(@"UIDsauvé");
	} else {
		[defaults removeObjectForKey:@"FBUserId"];
	}
	
	NSString *access_token = _facebook.accessToken;
	if ((access_token != (NSString *) [NSNull null]) && (access_token.length > 0)) {
		[defaults setObject:access_token forKey:@"FBAccessToken"];
			NSLog(@"TOKENsauvé");
	} else {
		[defaults removeObjectForKey:@"FBAccessToken"];
	}
	
	NSDate *expirationDate = _facebook.expirationDate;  
	if (expirationDate) {
		[defaults setObject:expirationDate forKey:@"FBSessionExpires"];
			NSLog(@"EXPIRATIONsauvé");
	} else {
		[defaults removeObjectForKey:@"FBSessionExpires"];
	}
	
	[defaults synchronize];
		
}

- (void) unsave {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBUserId"];
	[defaults removeObjectForKey:@"FBAccessToken"];
	[defaults removeObjectForKey:@"FBSessionExpires"];
	[defaults synchronize]; 

}

- (id) restore {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *uid = [defaults objectForKey:@"FBUserId"];
	if (uid) {
		NSDate* expirationDate = [defaults objectForKey:@"FBSessionExpires"];
		if (!expirationDate || [expirationDate timeIntervalSinceNow] > 0) {
			_uid = [uid copy];
			_facebook = [[Facebook alloc] init];
			_facebook.accessToken = [[defaults stringForKey:@"FBAccessToken"] copy];
			_facebook.expirationDate = [expirationDate retain];
			NSLog(@"restauré success");
			return _facebook;
		}
	}
	return nil;  
}
- (void) setSessionWithFacebook:(Facebook *)facebook andUid:(NSString *)uid {
	_facebook = [facebook retain];
	_uid = [uid retain];
	NSLog(@"set fb");
}
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
-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle{
	UIAlertView *alert;
	if([otherTitle isEqualToString:@""])
		alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:nil,nil];
	else 
		alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:otherTitle,nil];
	[alert show]; 
	[alert release];
}

@end


