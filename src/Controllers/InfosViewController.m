//
//  InfosViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "InfosViewController.h"
#import "SA_OAuthTwitterEngine.h"

#define kActionSheetVisitIleSansFil			2
#define kActionSheetCallIleSansFil			3
#define kActionSheetEmailIleSansFil			4
#define kActionSheetVisitTdo				5
#define kActionSheetVisitIWeb				6
#define kActionSheetVisitPatrick			7
#define kActionSheetVisitLaurent			8
#define kActionSheetVisitApache				9

#define kOAuthConsumerKey				@"E6naEMYeeVUVPrSkm1v8bg"		//REPLACE ME
#define kOAuthConsumerSecret			@"Tf7kKcb0c1d0YvxUjOfIbiMkDLk613VyBnEQ3kwtM"		//REPLACE ME

@implementation InfosViewController
@synthesize mainView;

- (void)viewDidLoad {
	[super viewDidLoad];
	[infosImage setImage:[UIImage imageNamed:NSLocalizedString(@"infosImage", @"")]];
	[ISFButton setImage:[UIImage imageNamed:NSLocalizedString(@"isfButton", @"")] forState:UIControlStateNormal];
	[CreditsButton setImage:[UIImage imageNamed:NSLocalizedString(@"isfCreditsImage", @"")] forState:UIControlStateNormal];
	[GuideButton setImage:[UIImage imageNamed:NSLocalizedString(@"btn_notice",@"")]	 forState:UIControlStateNormal];
	
	[ISFInfosImage setImage:[UIImage imageNamed:NSLocalizedString(@"isfInfosImage", @"")]];
	[ISFInfosNotice setImage:[UIImage imageNamed:NSLocalizedString(@"isfInfosNotice", @"")]];
	[backButton setImage:[UIImage imageNamed:NSLocalizedString(@"backButton", @"")] forState:UIControlStateNormal];
	[backButton2 setImage:[UIImage imageNamed:NSLocalizedString(@"backButton", @"")] forState:UIControlStateNormal];
	[backButton3 setImage:[UIImage imageNamed:NSLocalizedString(@"backButton", @"")] forState:UIControlStateNormal];
	[bt_settings setImage:[UIImage imageNamed:NSLocalizedString(@"bt_settings",@"")] forState:UIControlStateNormal];
	
	lasettingsviewcontroller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
	
	NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
	NSLog(@"version : %@",versionString);

	
	versionLabel.text=[@"Version : " stringByAppendingFormat:versionString]; 
	NavigationBar.title=NSLocalizedString(@"Informations",@"");
	
	isMainView = YES;
	
	
	infos.text=NSLocalizedString(@"textinfo",@"");
	scroll.contentSize = CGSizeMake(320, 241);
	
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[lasettingsviewcontroller viewWillAppear:YES];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)flipViews {
	if (isMainView == YES) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:ISFView];
		[UIView commitAnimations];
		isMainView = NO;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[ISFView removeFromSuperview];
		[self.view addSubview:mainView];
		[UIView commitAnimations];
		isMainView = YES;
	}

}
- (IBAction)flipViews2 {
	if (isMainView == YES) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:CreditsView];
		[UIView commitAnimations];
		isMainView = NO;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[ISFView removeFromSuperview];
		[self.view addSubview:mainView];
		[UIView commitAnimations];
		isMainView = YES;
	}
	
}
- (IBAction)flipViews3 {
	if (isMainView == YES) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:GuideView];
		[UIView commitAnimations];
		isMainView = NO;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[ISFView removeFromSuperview];
		[self.view addSubview:mainView];
		[UIView commitAnimations];
		isMainView = YES;
	}
	
}
- (IBAction)flipViews4 {
	if (isMainView == YES) {
		/*		[UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:1.0];
		 [UIView setAnimationBeginsFromCurrentState:NO];
		 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		 [mainView removeFromSuperview];
		 [self.view addSubview:settingsView];
		 [UIView commitAnimations];
		 isMainView = NO;*/
		/*	}
		 else {
		 [UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:1.0];
		 [UIView setAnimationBeginsFromCurrentState:NO];
		 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		 [settingsView removeFromSuperview];
		 [self.view addSubview:mainView];
		 [UIView commitAnimations];
		 isMainView = YES;
		 }
		 */
		
		//[self.navigationController pushViewController:twitterviewcontroller animated:YES];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationBeginsFromCurrentState:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:lasettingsviewcontroller.view];
		[UIView commitAnimations];
		isMainView = NO;
	}
}
- (IBAction)visitIleSansFil {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the Île sans fil website?", @"")
																				delegate:self 
																	cancelButtonTitle:NSLocalizedString(@"No", @"") 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitIleSansFil;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)visitTdo {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the Thomas Dobranowski website?", @"")
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"No", @"") 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitTdo;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)visitIWeb {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the iWeb website?", @"")
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"No", @"") 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitIWeb;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)visitPatrick {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the Patrick Boucher website?", @"")
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"No", @"") 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitPatrick;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)visitLaurent {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the Laurent Maisonnave website?", @"")
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"No", @"") 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitLaurent;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)visitApache {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Visit the ile sans fil website Apache 2.0 license?", @"")
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"No", @"") 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetVisitApache;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}
- (IBAction)callIleSansFil {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Call Île sans fil?", @"")
																				delegate:self 
																	cancelButtonTitle:NSLocalizedString(@"No", @"") 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetCallIleSansFil;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}

- (IBAction)emailIleSansFil {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Send an email to Île sans fil?", @"")
																				delegate:self 
																	cancelButtonTitle:NSLocalizedString(@"No", @"") 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = kActionSheetEmailIleSansFil;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (actionSheet.tag) {
		case kActionSheetVisitIleSansFil:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.ilesansfil.org"]];
			}
			break;
		case kActionSheetVisitTdo:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://ca.linkedin.com/pub/thomas-dobranowski/12/840/b75"]];
			}
			break;
		case kActionSheetVisitIWeb:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://iweb.ca"]];
			}
			break;
		case kActionSheetVisitPatrick:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://twitter.com/pboucher"]];
			}
			break;
		case kActionSheetVisitLaurent:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.zelaurent.com/"]];
			}
			break;
			break;
		case kActionSheetVisitApache:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"site apache",@"")]];
			}
			break;
		case kActionSheetCallIleSansFil:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"tel:+15143161621"]];
			}
			break;
		case kActionSheetEmailIleSansFil:
			if (buttonIndex == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"mailto:info@ilesansfil.org"]];
			}
			break;
		default:
			break;
	}
}
-(IBAction)deleteCacheTwitter {
	
	if (!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
		[_engine clearAccessToken];
	
	
}
-(void)setisMainView:(BOOL)ismainview {
	isMainView=ismainview;
}
@end
