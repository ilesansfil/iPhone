//
//  CreditsViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 21/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CreditsViewController  : UIViewController  <UIActionSheetDelegate> {
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
