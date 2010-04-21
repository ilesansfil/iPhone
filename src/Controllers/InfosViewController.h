//
//  InfosViewController.h
//  Ile sans fil
//
//  Created by Oli on 09-10-06.
//  Copyright 2009 Kolt Production. All rights reserved.
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
	BOOL	isMainView;
}

- (IBAction)flipViews;
- (IBAction)flipViews2;
- (IBAction)visitIleSansFil;
- (IBAction)visitIWeb;
- (IBAction)visitTdo;
- (IBAction)callIleSansFil;
- (IBAction)emailIleSansFil;

@end
