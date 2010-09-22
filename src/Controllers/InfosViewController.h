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
	
	//IBOutlet UITextView			*Credits;
	
	IBOutlet UIView			*ISFView;
	IBOutlet UIView			*CreditsView;
	IBOutlet UIImageView		*ISFInfosImage;
	IBOutlet UIButton			*backButton;
	IBOutlet UIButton			*backButton2;
	IBOutlet UILabel			*versionLabel;
		
	BOOL	isMainView;
}

- (IBAction)flipViews;
- (IBAction)flipViews2;
- (IBAction)visitIleSansFil;
- (IBAction)visitIWeb;
- (IBAction)visitTdo;
- (IBAction)visitPatrick;
- (IBAction)visitLaurent;
- (IBAction)visitApache;
- (IBAction)callIleSansFil;
- (IBAction)emailIleSansFil;

@end
