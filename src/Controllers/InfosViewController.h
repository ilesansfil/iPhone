//
//  InfosViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "settingsViewController.h"

@class SA_OAuthTwitterEngine;

@interface InfosViewController : UIViewController  <SA_OAuthTwitterControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UIView			*mainView;
	IBOutlet UIImageView		*infosImage;
	IBOutlet UIButton			*ISFButton;
	IBOutlet UIButton			*CreditsButton;
	IBOutlet UIButton			*GuideButton;
	IBOutlet UITextView			*infos;
	
	IBOutlet UIView			*GuideView;
	IBOutlet UIView			*ISFView;
	IBOutlet UIView			*CreditsView;
	IBOutlet UIView			*settingsView;
	IBOutlet UIImageView		*ISFInfosImage;
	IBOutlet UIImageView		*ISFInfosNotice;
	IBOutlet UIButton			*backButton;
	IBOutlet UIButton			*backButton2;
	IBOutlet UIButton			*backButton3;
	IBOutlet UILabel			*versionLabel;
	IBOutlet UINavigationItem	*NavigationBar;
	IBOutlet UIButton			*bt_settings;
	SA_OAuthTwitterEngine				*_engine;
	settingsViewController				*lasettingsviewcontroller;
	BOOL	isMainView;
}

- (IBAction)flipViews;
- (IBAction)flipViews2;
- (IBAction)flipViews3;
- (IBAction)flipViews4;
- (IBAction)visitIleSansFil;
- (IBAction)visitIWeb;
- (IBAction)visitTdo;
- (IBAction)visitPatrick;
- (IBAction)visitLaurent;
- (IBAction)visitApache;
- (IBAction)callIleSansFil;
- (IBAction)emailIleSansFil;
-(IBAction)deleteCacheTwitter;

@end
