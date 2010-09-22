//
//  RootViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "RootViewController.h"
#import "MapViewController.h"
#import "XMLReader.h"
#import "Hotspot.h"


@implementation RootViewController


- (void)viewDidLoad {
	[super viewDidLoad];

	mapButton.title	= NSLocalizedString(@"Hotspots", @"");
	newsButton.title	= NSLocalizedString(@"News", @"");
	infosButton.title	= NSLocalizedString(@"Informations", @"");
	favoritesButton.title	= NSLocalizedString(@"Favorites", @"");
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITabBar2.png"]];
	img.frame = CGRectOffset(img.frame, 0, 1);
	[latabbar insertSubview:img atIndex:0];
	[img release];
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

