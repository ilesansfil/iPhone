//
//  TwitterViewController.h
//  PCMTL '10
//
//  Created by thomas dobranowski on 01/09/10.
//  Copyright 2010 podcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface TwitterViewController : UIViewController  <SA_OAuthTwitterControllerDelegate, UITextViewDelegate> {
	SA_OAuthTwitterEngine				*_engine;
	IBOutlet UITextView					*message;
	IBOutlet UIButton					*bt_send;
	IBOutlet UILabel				*nbcharacter;
}
-(IBAction)send;
-(void) setmessage:(NSString*)lemessage;
-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle;


@end
