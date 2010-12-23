//
//  TwitterViewController.h
//  PCMTL '10
//
//  Created by thomas dobranowski on 01/09/10.
//  Copyright 2010 podcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "UserRequestResult.h"

@class FBSession;
@class SA_OAuthTwitterEngine;

@interface SettingsViewController : UIViewController  <SA_OAuthTwitterControllerDelegate, UITextViewDelegate,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,FBRequestDelegate,FBDialogDelegate,FBSessionDelegate, UserRequestDelegate>{
	
	/*IBOutlet FBLoginButton* _fbButton;*/
	IBOutlet UIButton* _getUserInfoButton;
	IBOutlet UIButton* _getPublicInfoButton;
	IBOutlet UIButton* _publishButton;
	IBOutlet UIButton* _uploadPhotoButton;
	Facebook* _facebook;
	NSString *_uid;
	NSString *nameofUser;
	NSArray* _permissions;
	BOOL Facebook_islogin;
	
	IBOutlet UITableView			*_tableView;
	SA_OAuthTwitterEngine				*_engine;
	IBOutlet UITextView					*message;
	IBOutlet UIButton					*bt_send;
	IBOutlet UILabel				*nbcharacter;
	IBOutlet UIButton				*back;
}


/*-(IBAction)send;
 -(void) setmessage:(NSString*)lemessage;
 -(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle;
 */
-(IBAction)back;
- (void) getUsername;
- (void)request:(FBRequest*)request didLoad:(id)result;
- (void)userRequestCompleteWithUid:(NSString *)uid;
- (void) setSessionWithFacebook:(Facebook *)facebook andUid:(NSString *)uid;
- (void) save;
- (void) unsave;
- (id) restore;
- (void) login;
- (void) logout;
- (BOOL)isConnectionAvailable;
-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle;
@property (nonatomic, retain) NSString *nameofUser;

@end
