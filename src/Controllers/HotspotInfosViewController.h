//
//  HotspotInfosViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
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
	//UIButton *btn;
	BOOL exist;
	
}


//@property (nonatomic, retain) UIButton *btn;
@property (nonatomic, retain) Hotspot *hotspot;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoords;
@property (nonatomic, assign) BOOL exist;

//- (id)initWithBackImageNamed:(NSString*)imageName;

- (void)confirmMap;
- (void)showMap;
- (void)confirmPhone;
- (void)callPhone;
- (void)confirmEmail;
- (void)sendEmail;
- (void)showDirections;
- (void)AddDeleteFavorite:(BOOL )action;

//- (IBAction)closeView;

@end
