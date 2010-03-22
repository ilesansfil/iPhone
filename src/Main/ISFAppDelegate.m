//
//  Ile_sans_filAppDelegate.m
//  Ile sans fil
//
//  Created by Oli on 09-10-03.
//  Copyright Kolt Production 2009. All rights reserved.
//

#import "ISFAppDelegate.h"
#import "RootViewController.h"
#import "FlurryAPI.h"


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
	[window makeKeyAndVisible];
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

