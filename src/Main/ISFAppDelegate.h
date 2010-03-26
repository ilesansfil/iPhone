//
//  Ile_sans_filAppDelegate.h
//  Ile sans fil
//
//  Created by Oli on 09-10-03.
//  Copyright Kolt Production 2009. All rights reserved.
//

@interface ISFAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
	
	BOOL isLoadingData;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) BOOL isLoadingData;


+ (ISFAppDelegate *)appDelegate;
- (void)showNetworkActivity:(BOOL)active;

@end
