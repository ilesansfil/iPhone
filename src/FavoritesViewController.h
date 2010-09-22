//
//  FavoritesViewController.h
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
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
