//
//  InfosViewController.m
//  Ile sans fil
//
//  Created by Oli on 09-10-06.
//  Copyright 2009 Kolt Production. All rights reserved.
//

#import "InfosViewController.h"


#define kActionSheetVisitIleSansFil			2
#define kActionSheetCallIleSansFil			3
#define kActionSheetEmailIleSansFil			4

@implementation InfosViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	[infosImage setImage:[UIImage imageNamed:NSLocalizedString(@"infosImage", @"")]];
	[ISFButton setImage:[UIImage imageNamed:NSLocalizedString(@"isfButton", @"")] forState:UIControlStateNormal];

	[ISFInfosImage setImage:[UIImage imageNamed:NSLocalizedString(@"isfInfosImage", @"")]];
	[backButton setImage:[UIImage imageNamed:NSLocalizedString(@"backButton", @"")] forState:UIControlStateNormal];
	
	isMainView = YES;
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

@end
