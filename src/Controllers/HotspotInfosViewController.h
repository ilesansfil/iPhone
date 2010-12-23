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
#import "MapViewController.h"
#import "TwitterViewController.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "UserRequestResult.h"

//@class FBSession;
@class Favorite;

@interface HotspotInfosViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,FBRequestDelegate,FBDialogDelegate,FBSessionDelegate, UserRequestDelegate>{
	IBOutlet UILabel* _label;
	IBOutlet FBLoginButton* _fbButton;
	IBOutlet UIButton* _getUserInfoButton;
	IBOutlet UIButton* _getPublicInfoButton;
	IBOutlet UIButton* _publishButton;
	IBOutlet UIButton* _uploadPhotoButton;
	Facebook* _facebook;
	  NSString *_uid;
	NSArray* _permissions;
	
	
	IBOutlet UITableView			*_tableView;
	IBOutlet UINavigationBar	*_navBar;
	NSMutableArray					*infos;
	Hotspot 							*hotspot;
	CLLocationCoordinate2D		 currentCoords;
	BOOL exist;
	TwitterViewController *twitterviewcontroller;
}


@property (nonatomic, retain) Hotspot *hotspot;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoords;
@property (nonatomic, assign) BOOL exist;
@property(nonatomic,readonly) UILabel* label;

//- (id)initWithBackImageNamed:(NSString*)imageName;

- (void)confirmMap;
- (void)showMap;
- (void)confirmPhone;
- (void)callPhone;
- (void)confirmEmail;
- (void)sendEmail;
- (void)showDirections;
- (IBAction)AddDeleteFavorite;

//- (IBAction)closeView;

- (void)userRequestCompleteWithUid:(NSString *)uid;
- (void) setSessionWithFacebook:(Facebook *)facebook andUid:(NSString *)uid;
- (void) save;
- (void) unsave;
- (id) restore;
-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle;
- (BOOL)isConnectionAvailable;

@end
