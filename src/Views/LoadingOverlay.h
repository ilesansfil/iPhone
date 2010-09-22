//
//  LoadingOverlay.h
//  RedNest
//
//  Created by Olivier Collet on 09-10-07.
//  Copyright 2009 WhereCloud Inc. License Apache2.
//

#import <UIKit/UIKit.h>


@interface LoadingOverlay : NSObject {
	BOOL onScreen;
	UIView						*overlayView;
	UIActivityIndicatorView	*spinner;
	UILabel						*messageLabel;
}

+ (id)overlayInstance;
- (void)showMessage:(NSString *)aMessage inViewController:(UIViewController *)aViewController;
- (void)hide;

@end
