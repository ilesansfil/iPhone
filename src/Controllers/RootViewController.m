//
//  RootViewController.m
//  Ile sans fil
//
//  Created by Oli on 09-10-03.
//  Copyright Kolt Production 2009. All rights reserved.
//

#import "RootViewController.h"
#import "MapViewController.h"
#import "XMLReader.h"
#import "Hotspot.h"


@implementation RootViewController


- (void)viewDidLoad {
	[super viewDidLoad];

	mapButton.title	= NSLocalizedString(@"Map", @"");
	newsButton.title	= NSLocalizedString(@"News", @"");
	infosButton.title	= NSLocalizedString(@"Informations", @"");
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
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
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end

