//
//  FavoritesViewController.h
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MapViewController.h"

@class MapViewController;
@interface FavoritesViewController : UITableViewController {
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet UIView *view;
	IBOutlet MapViewController *mapViewController;
	NSMutableArray *favoritesArray;
}

@property (nonatomic, retain) NSMutableArray *favoritesArray;

@end
