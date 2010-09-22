//
//  Ile_sans_filAppDelegate.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
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
