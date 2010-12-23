//
//  TwitterViewController.m
//  PCMTL '10
//
//  Created by thomas dobranowski on 01/09/10.
//  Copyright 2010 podcamp. All rights reserved.
//

#import "SettingsViewController.h"
#import "SA_OAuthTwitterEngine.h"
#import "ISFAppDelegate.h"
#import "InfosViewController.h"
#import "FBConnect.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define kOAuthConsumerKey				@"eFeb0xEObJz1rdzLgdk9Q"		//REPLACE ME
#define kOAuthConsumerSecret			@"xFjWZVN1OYUXqgjhuXrl4aWCM8ZsLSFk4MNdwwO6Jww"		//REPLACE ME

#define kSectionTwitter			0
#define kSectionBt_Twitter		1
#define kSectionFacebook		2
#define kSectionBt_Facebook		3


static NSString* kAppId = @"154563301232449";



@implementation SettingsViewController

@synthesize nameofUser;



//=============================================================================================================================
#pragma mark ViewController Stuff
- (void)dealloc {
	[_engine release];
	[_facebook release];
	[_uid release];
	[nameofUser release];
	[_permissions release];
	
    [super dealloc];
}
- (void) viewDidAppear: (BOOL)animated {
	
	
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
	nameofUser=@" ";
	_facebook = [[self restore] retain];
	if (_facebook == nil) {
		_facebook = [[Facebook alloc] init];
		Facebook_islogin = NO;
		NSLog(@"PAS LOGUER");
	} else {
		Facebook_islogin = YES;
		//[self fbDidLogin];
		[self getUsername];
		NSLog(@"restore LOGUé");
	}
	[_tableView reloadData];
	
	
}
-(void) viewDidLoad {
	Facebook_islogin = NO;
	[back setImage:[UIImage imageNamed:NSLocalizedString(@"backButton", @"")] forState:UIControlStateNormal];

	
	
	
	//	NSLog(@"isvalid %@",[_facebook isSessionValid]);
}

-(IBAction)NewAccount {
	
	if (!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
}



- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}/*
  -(IBAction)deleteCacheTwitter {
  
  //extractUsernameFromHTTPBody: (NSString *) body
  //	NSString * Key=[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
  
  //	NSLog(@"le nom est : %@",[_engine extractUsernameFromHTTPBody:Key]);
  if (!_engine){
  _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
  _engine.consumerKey = kOAuthConsumerKey;
  _engine.consumerSecret = kOAuthConsumerSecret;
  }
  [self  storeCachedTwitterOAuthData: @"" forUsername:@""];
  [_engine clearAccessToken];
  //	NSLog(@"tooo %@ :",[_engine.]);
  
  }
  -(IBAction)deleteCacheFacebook {
  
  
  }*/
-(IBAction)back {
	
	
	ISFAppDelegate *appDelegate = (ISFAppDelegate *)[[UIApplication sharedApplication] delegate];
	InfosViewController *infos=[[appDelegate.tabBarController viewControllers] objectAtIndex:3];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationBeginsFromCurrentState:NO];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:infos.view cache:YES];
	[self.view removeFromSuperview];
	[infos.view addSubview:infos.mainView];
	[UIView commitAnimations];
	[infos setisMainView:YES];
	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger nbSections = 4;
	
	return nbSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//if (section == kSectionTwitter) return 1;
	//if (section == kSectionFacebook) return 1;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//if (indexPath.section == kSectionInfos && indexPath.row == kRowTagAddress) return 60.0f;
	return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section != kSectionTwitter && section != kSectionFacebook) return nil;
	
	//CGSize size = [hotspot.name sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(280, 80) lineBreakMode:UILineBreakModeWordWrap];
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40.0f)] autorelease];
	//	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, size.height+10)] autorelease];
	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 10, 200, 30)] autorelease];
	nameLabel.backgroundColor = [UIColor clearColor];
	
	
	UIImageView *imageView;
	
	
	
	
	/*	if(section==kSectionTwitter)
	 {
	 //nameLabel.text = @"Twitter Account";
	 
	 imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20,20)] autorelease];
	 imageView.image = [UIImage imageNamed:@"logo_twitter.png"];
	 
	 
	 
	 }else if (section==kSectionFacebook) {
	 //	nameLabel.text = @"Facebook Account";
	 
	 imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20,20)] autorelease];
	 imageView.image = [UIImage imageNamed:@"logo_facebook.png"];
	 
	 
	 
	 }
	 */
	nameLabel.font = [UIFont boldSystemFontOfSize:17];
	nameLabel.shadowColor = [UIColor whiteColor];
	nameLabel.shadowOffset = CGSizeMake(0, 1);
	nameLabel.numberOfLines = 3;
	//	[headerView addSubview:nameLabel];
	//	[headerView addSubview:imageView];
	
	
	
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	static NSString *DefaultCellIdentifier = @"DefaultCell";
	static NSString *ButtonCellIdentifier	= @"ButtonCell";
	UIImageView *imageView;
	UIImageView *imageView2;
	NSUserDefaults *prefs;
	NSString *userNameFB;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
	if (cell == nil) {
		if (indexPath.section == kSectionBt_Facebook) { 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];
		} else {
			if (indexPath.section == kSectionBt_Twitter) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];
			else cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier] autorelease];
		}
	}
	//UIImage *img2;
	
	
	switch (indexPath.section) {
		case kSectionTwitter:
			cell.textLabel.text 			= NSLocalizedString(@"",@"");
			cell.textLabel.numberOfLines=1;
			
			NSString * Key=[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
			
			
			
			imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 30,30)] autorelease];
			imageView.image = [UIImage imageNamed:@"logo_twitter.png"];
			[cell.contentView addSubview:imageView];
			
			
			if([_engine extractUsernameFromHTTPBody:Key])
			{
				
				cell.textLabel.text	= [@"@" stringByAppendingString:[_engine extractUsernameFromHTTPBody:Key]];
			}else {
				
				cell.textLabel.text=@" ";
				
			}
			
			
			
			
			
			
			
			cell.textLabel.font= [UIFont systemFontOfSize:20];
			cell.textLabel.textAlignment=UITextAlignmentCenter;
			cell.userInteractionEnabled=FALSE;
			
			/*	id path = @"tdoone";
			 NSURL *url = [NSURL URLWithString:path];
			 NSData *data = [NSData dataWithContentsOfURL:url];
			 UIImage *img = [[UIImage alloc] initWithData:data];
			 
			 UIImageView *Image = [[[UIImageView alloc] initWithImage:[images objectAtIndex:storyIndex]] autorelease];
			 CGRect imageFrame = Image.frame;
			 imageFrame.origin = CGPointMake(2, 2);
			 Image.frame = CGRectMake(5.0, 8.0, 38.0, 38.0);
			 Image.tag = 5;
			 Image.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			 [cell.contentView addSubview:Image];
			 */
			break;
		case kSectionFacebook:
			
			cell.textLabel.text 			= NSLocalizedString(@"",@"");
			cell.textLabel.numberOfLines=1;
			
			prefs = [NSUserDefaults standardUserDefaults];
			userNameFB=[prefs stringForKey:@"userNameFB"];
			
			imageView2=[[[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 30,30)] autorelease];
			imageView2.image = [UIImage imageNamed:@"logo_facebook.png"];
			[cell.contentView addSubview:imageView2];
			
			
			if(Facebook_islogin)
			{
				
				
				cell.textLabel.text	= userNameFB;
				if(![nameofUser isEqualToString:@" "])
				cell.textLabel.text=nameofUser;
				//cell.detailTextLabel.text	= nameofUser;
				
			}else {
				//cell.textLabel.text=nameofUser;
				cell.textLabel.text=@" ";
				cell.textLabel.text	= userNameFB;
			}
			
			cell.textLabel.font= [UIFont systemFontOfSize:20];
			cell.userInteractionEnabled=FALSE;
			cell.textLabel.textAlignment	= UITextAlignmentCenter;
			break;
		case kSectionBt_Twitter:
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];
			
			
			//if([[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"] isEqualToString:@""])
			//{
			NSString * Key2=[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
			
			if(![_engine extractUsernameFromHTTPBody:Key2])
			{
				cell.textLabel.text				= NSLocalizedString(@"New Twitter Account", @"");
				cell.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
				//	[cell setTextColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1.0]];
			}else {
				cell.textLabel.text				= NSLocalizedString(@"Delete Twitter Account", @"");
				cell.backgroundColor = [UIColor colorWithRed:184.0/255 green:8.0/255 blue:8.0/255 alpha:1.0];
				//[cell setTextColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0]];
			}
			
			
			cell.textLabel.textAlignment	= UITextAlignmentCenter;
			//	img2= [UIImage imageNamed:@"direction.png"];
			//cell.imageView.image = img2;
			break;
		case kSectionBt_Facebook:
			if(Facebook_islogin)
			{
				cell.textLabel.text				= NSLocalizedString(@"Delete Facebook Account", @"");
				cell.backgroundColor = [UIColor colorWithRed:184.0/255 green:8.0/255 blue:8.0/255 alpha:1.0];
				//[cell setTextColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0]];
			}else {
				
				prefs = [NSUserDefaults standardUserDefaults];
				userNameFB=[prefs stringForKey:@"userNameFB"];
				
				if(![userNameFB isEqualToString:@" "])
				{
					cell.textLabel.text				= NSLocalizedString(@"Delete Facebook Account", @"");
					cell.backgroundColor = [UIColor colorWithRed:184.0/255 green:8.0/255 blue:8.0/255 alpha:1.0];
				}else{
					cell.textLabel.text				= NSLocalizedString(@"New Facebook Account", @"");
					cell.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
					//[cell setTextColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1.0]];
				}
			}
			cell.textLabel.textAlignment	= UITextAlignmentCenter;
			//img2= [UIImage imageNamed:@"direction.png"];
			//cell.imageView.image = img2;
			
			break;
		default:
			break;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSUserDefaults *prefs;
	NSString *userNameFB;
	if (!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
	switch (indexPath.section) {
		case kSectionBt_Twitter:
			
			if([[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"] isEqualToString:@""])
			{
				if([self isConnectionAvailable])
				{
				
				
					UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
				
					if (controller) 
						[self presentModalViewController: controller animated: YES];
					
				
				}else {
					[self alertNotice:@"" withMSG:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network.",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
				}
			}else {
				[_engine clearAccessToken];
				[self  storeCachedTwitterOAuthData: @"" forUsername:@""];
				//	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
				//[controller ]
			}
			
			[_tableView reloadData];
			
			break;
		case kSectionBt_Facebook:
			//	[self confirmPhone];
			prefs = [NSUserDefaults standardUserDefaults];
			userNameFB=[prefs stringForKey:@"userNameFB"];
			if (Facebook_islogin) {
				Facebook_islogin=NO;
				[self logout];
				[self unsave];
				[self setNameofUser:@" "];
				NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
				[prefs setObject:@" " forKey:@"userNameFB"];
				[_tableView reloadData];
			} else {
				if(![userNameFB isEqualToString:@" "])
				{
					Facebook_islogin=NO;
					[self logout];
					[self unsave];
					[self setNameofUser:@" "];
					NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
					[prefs setObject:@" " forKey:@"userNameFB"];
					[_tableView reloadData];
					
				}else{
					if([self isConnectionAvailable])
					{
						[self login];
					}else {
						[self alertNotice:@"" withMSG:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network.",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
					}
					
				}
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


/**
 * Example of graph API CAll
 *
 * This lets you make a Graph API Call to get the information of current logged in user.
 */
- (void) getUsername {
	[_facebook requestWithGraphPath:@"me" andDelegate:self];
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
	
	_getUserInfoButton.hidden    = NO;
	_getPublicInfoButton.hidden   = NO;
	_publishButton.hidden        = NO;
	_uploadPhotoButton.hidden    = NO;
	Facebook_islogin         = YES;
	
	UserRequestResult *userRequestResult = [[[[UserRequestResult alloc] initializeWithDelegate:self] autorelease] retain];
	[_facebook requestWithGraphPath:@"me" andDelegate:userRequestResult];
	
	
	
	
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
	
	_getUserInfoButton.hidden    = YES;
	_getPublicInfoButton.hidden   = YES;
	_publishButton.hidden        = YES;
	_uploadPhotoButton.hidden = YES;
	Facebook_islogin         = NO;
	//[_fbButton updateImage];
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
	NSLog(@"error : %@",[error localizedDescription]);
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
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:(NSString *)[NSString stringWithFormat:@"%@",[result objectForKey:@"name"]] forKey:@"userNameFB"];
	[self setNameofUser:(NSString *)[NSString stringWithFormat:@"%@",[result objectForKey:@"name"]]];//[result objectForKey:@"name"]];
	//NSLog(@"name %@",[result objectForKey:@"name"]);
	//NSLog(@"name2 %@",nameofUser);
	
	
	[_tableView reloadData];
};

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/** 
 * Called when a UIServer Dialog successfully return
 */
- (void)dialogDidComplete:(FBDialog*)dialog{
	//[self.label setText:@"publish successfully"];
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
			NSLog(@"restore success");
			return _facebook;
		}
	}
	return nil;  
}
- (void) setSessionWithFacebook:(Facebook *)facebook andUid:(NSString *)uid {
	_facebook = [facebook retain];
	_uid = [uid retain];
	
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

