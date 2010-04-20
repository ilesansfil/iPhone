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
	//IBOutlet UITextView			*Credits;
	
	IBOutlet UIView			*ISFView;
	IBOutlet UIImageView		*ISFInfosImage;
	IBOutlet UIButton			*backButton;
	
	BOOL	isMainView;
}

- (IBAction)flipViews;
- (IBAction)visitIleSansFil;
- (IBAction)callIleSansFil;
- (IBAction)emailIleSansFil;

@end
