//
//  HotspotInfosViewController.h
//  Ile sans fil
//
//  Created by Oli on 09-10-06.
//  Copyright 2009 Kolt Production. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Hotspot.h"

@class Favorite;

@interface HotspotInfosViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet UITableView			*_tableView;
	IBOutlet UINavigationBar	*_navBar;
	NSMutableArray					*infos;
	Hotspot 							*hotspot;
	CLLocationCoordinate2D		 currentCoords;
	UIButton *btn;
	BOOL exist;
	
}

@property (nonatomic, retain) Hotspot *hotspot;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoords;
@property (nonatomic, assign) BOOL exist;

- (void)confirmMap;
- (void)showMap;
- (void)confirmPhone;
- (void)callPhone;
- (void)confirmEmail;
- (void)sendEmail;
- (void)showDirections;
- (void)AddDeleteFavorite:(BOOL )action;

@end
