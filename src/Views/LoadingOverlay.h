//
//  LoadingOverlay.h
//  RedNest
//
//  
//  Copyright 2009 License Apache2.
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
