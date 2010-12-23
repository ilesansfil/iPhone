    //
//  TwitterViewController.m
//  PCMTL '10
//
//  Created by thomas dobranowski on 01/09/10.
//  Copyright 2010 podcamp. All rights reserved.
//

#import "TwitterViewController.h"
#import "SA_OAuthTwitterEngine.h"


#define kOAuthConsumerKey				@"eFeb0xEObJz1rdzLgdk9Q"		//REPLACE ME
#define kOAuthConsumerSecret			@"xFjWZVN1OYUXqgjhuXrl4aWCM8ZsLSFk4MNdwwO6Jww"		//REPLACE ME

@implementation TwitterViewController



//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
	
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
	
	[self alertNotice:@"" withMSG:NSLocalizedString(@"Message bien envoyé",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
	
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	
	[self alertNotice:@"" withMSG:NSLocalizedString(@"Erreur d'envoi du message",@"") cancleButtonTitle:@"OK" otherButtonTitle:@""];
}



//=============================================================================================================================
#pragma mark ViewController Stuff
- (void)dealloc {
	[_engine release];
    [super dealloc];
}
- (void) viewDidAppear: (BOOL)animated {

	//else {
		
	//	[_engine sendUpdate: [NSString stringWithFormat: @"Already Updated blablabla TEST. %@", [NSDate date]]];
	//}
	//message.returnKeyType = UIReturnKeyDone ;
//	message.delegate = self;
	nbcharacter.text= [NSString stringWithFormat:@"%d", [message.text length]];
}
-(void) viewDidLoad {

	if (_engine) return;
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
}
-(void) setmessage:(NSString*)lemessage {
	message.text=lemessage;
	
	
}
-(IBAction)send {

	if (!_engine){
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	}
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else {
		
		[_engine sendUpdate:message.text]; /*[NSString stringWithFormat: @"Already Updated blablabla TEST. %@", [NSDate date]]]*/;
	}
	
	[message resignFirstResponder];
	//NSLog([self cachedTwitterOAuthDataForUsername:@""],@"");
	[self.navigationController popViewControllerAnimated:YES];
	//[_engine clearAccessToken];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	nbcharacter.text= [NSString stringWithFormat:@"%d", [message.text length]];
   if([message.text length]>=139)
   {
	   message.text=[message.text substringWithRange:NSMakeRange(0,139)];
   }
	// Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
		
		if (!_engine){
			_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
			_engine.consumerKey = kOAuthConsumerKey;
			_engine.consumerSecret = kOAuthConsumerSecret;
		}
		UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
		
		if (controller) 
			[self presentModalViewController: controller animated: YES];
		else {
			
			[_engine sendUpdate:message.text]; /*[NSString stringWithFormat: @"Already Updated blablabla TEST. %@", [NSDate date]]]*/;
		}
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
	
    return TRUE;
}

-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle{
	UIAlertView *alert;
	if([otherTitle isEqualToString:@""])
		alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:nil,nil];
	else 
		alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:otherTitle,nil];
	[alert show]; 
	[alert release];
}
@end