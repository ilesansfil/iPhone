//
//  Ile_sans_filAppDelegate.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "ISFAppDelegate.h"
#import "RootViewController.h"
#import "FlurryAPI.h"
#import "NewsViewController.h"



@implementation ISFAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize isLoadingData;

#pragma mark -
#pragma mark Application lifecycle


void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAPI startSessionWithLocationServices:@"ZFKIWCLDGIHM4Z5Q1B2E"];
	
    // Override point for customization after app launch    
	
	
	
	[window addSubview:[tabBarController view]];
//	[[[[[[tabBarController viewControllers] objectAtIndex:0] navigationController] viewControllers]objectAtIndex:0] refreshAnnotations:@"toto"];
	[window makeKeyAndVisible];
	
	NSLog(@"Registering for push notifications...");    
#if !TARGET_IPHONE_SIMULATOR
	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif	
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken { 
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *saveSuccess=[prefs stringForKey:@"saveSuccess"];
	NSString *oldDeviceToken=[prefs stringForKey:@"deviceToken"];
	NSString *deviceToken = [[[[devToken description] 
							   stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];

	
	#if !TARGET_IPHONE_SIMULATOR
	if(![saveSuccess isEqualToString:@"success"] | ![deviceToken isEqualToString:oldDeviceToken] )
	{
		
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",devToken];
    
	NSLog(str,@"");
	
	
	

//	NSString *updateSuccess=[prefs stringForKey:@"updateSuccess"];
	//NSLog(@"success : %@ :",updateSuccess);
	
	
	
		// Get Bundle Info for Remote Registration (handy if you have more than one app)
		NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
		NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
		
		// Get the users Device Model, Display Name, Unique ID, Token & Version Number
		UIDevice *dev = [UIDevice currentDevice];
		NSString *deviceUuid = dev.uniqueIdentifier;
		NSString *deviceName = dev.name;
		NSString *deviceModel = dev.model;
		NSString *deviceSystemVersion = dev.systemVersion;
	
		// Prepare the Device Token for Registration (remove spaces and < >)
			
		// Build URL String for Registration
		// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
		// !!! SAMPLE: "secure.awesomeapp.com"
		//NSString *host = @"auth.ilesansfil.org/authpuppy/cms/Push";
		NSString *host = @"www.ilesansfil.org/wp-content/plugins/push-notification/";
		
		// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
		// !!! ( MUST START WITH / AND END WITH ? ). 
		// !!! SAMPLE: "/path/to/apns.php?"
		//	NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion];
		NSString *urlString = [NSString stringWithFormat:@"/20100713iphonescript.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion];
		
		NSHTTPURLResponse *response = NULL;
		NSError *error = NULL;
		// Register the Device Data
		// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
		NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	/*
	[request setHTTPMethod: @"POST"];
    [request setHTTPBody:postData];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];*/
	 NSHTTPURLResponse *httpResponse;
	
		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSLog(@"Register error: %@", error);
		NSLog(@"Register response: %@", response);
		NSLog(@"Register URL: %@", url);
		NSLog(@"Return Data: %@", returnData);
		httpResponse = (NSHTTPURLResponse *)response;
		int statusCode = [httpResponse statusCode];  
		NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
		NSLog(@"HTTP Status code: %d", statusCode);
	
		
		NSString *aStr = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
		if([aStr isEqualToString:@""])
		{
		NSLog(@"LES DATA%@fin",aStr);
		}else {
			NSLog(@"tototo");
		}

		[prefs setObject:deviceToken forKey:@"deviceToken"];
		if(statusCode<400 | statusCode==0)
		{
			if(![aStr isEqualToString:@""])
			{
			[prefs setObject:@"success" forKey:@"saveSuccess"];
			NSLog(@"success for registration");
			}
		}
		
	}
		
	NSLog(@"saveSuccess : %@",saveSuccess);
	
	#endif
	//[self alertNotice:@"" withMSG:[NSString stringWithFormat:@"devToken=%@",deviceToken] cancleButtonTitle:@"OK" otherButtonTitle:@""];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
	
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(str,@"");    
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	


	NSString *nbBadge; 
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
		
		//[self alertNotice:@"" withMSG:[NSString stringWithFormat:@"value: %@",[userInfo objectForKey:key]] cancleButtonTitle:@"OK" otherButtonTitle:@""];
		if([key isEqualToString:@"aps"])
		{
			nbBadge = [[userInfo objectForKey:key] objectForKey:@"badge"];
		
		//NSDictionary *bakery = [jsonResults objectForKey:@"badge" ];
		NSLog(@"NBbadge : %@", nbBadge);
	    [UIApplication sharedApplication].applicationIconBadgeNumber = [nbBadge integerValue] ;	
			
		}
    }

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

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}


+ (ISFAppDelegate *)appDelegate {
	return (ISFAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)showNetworkActivity:(BOOL)active {
	if (isLoadingData == YES) return;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = active;
}

@end

