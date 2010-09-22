//
//  InfosViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import <UIKit/UIKit.h>


@interface InfosViewController : UIViewController  <UIActionSheetDelegate> {
	IBOutlet UIView			*mainView;
	IBOutlet UIImageView		*infosImage;
	IBOutlet UIButton			*ISFButton;
	IBOutlet UIButton			*CreditsButton;
	IBOutlet UIButton			*GuideButton;
	IBOutlet UITextView			*infos;
	
	IBOutlet UIView			*GuideView;
	IBOutlet UIView			*ISFView;
	IBOutlet UIView			*CreditsView;
	IBOutlet UIImageView		*ISFInfosImage;
	IBOutlet UIImageView		*ISFInfosNotice;
	IBOutlet UIButton			*backButton;
	IBOutlet UIButton			*backButton2;
	IBOutlet UIButton			*backButton3;
	IBOutlet UILabel			*versionLabel;
		
	BOOL	isMainView;
}

- (IBAction)flipViews;
- (IBAction)flipViews2;
- (IBAction)flipViews3;
- (IBAction)visitIleSansFil;
- (IBAction)visitIWeb;
- (IBAction)visitTdo;
- (IBAction)visitPatrick;
- (IBAction)visitLaurent;
- (IBAction)visitApache;
- (IBAction)callIleSansFil;
- (IBAction)emailIleSansFil;

@end
