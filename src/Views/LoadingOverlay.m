//
//  LoadingOverlay.m
//  RedNest
//
//  Created by Olivier Collet on 09-10-07.
//  Copyright 2009 WhereCloud Inc. License Apache2.
//

#import "LoadingOverlay.h"


static LoadingOverlay *_overlayInstance;


@implementation LoadingOverlay


+ (id)overlayInstance {
	@synchronized(self) {
		if (!_overlayInstance) {
			_overlayInstance = [[[self class] alloc] init];
		}
	}
	return _overlayInstance;
}


- (void)dealloc {
	[overlayView release];
	[super dealloc];
}

- (void)showMessage:(NSString *)aMessage inViewController:(UIViewController *)aViewController {
	// First initialization
	if (overlayView == nil) {
		overlayView = [[UIView alloc] initWithFrame:CGRectInfinite];
		overlayView.backgroundColor = [UIColor blackColor];
		overlayView.alpha = 0.9f;
		
		spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		[spinner startAnimating];
		[overlayView addSubview:spinner];
		
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.font = [UIFont boldSystemFontOfSize:17];
		messageLabel.textAlignment = UITextAlignmentCenter;
		[overlayView addSubview:messageLabel];
	}
	overlayView.frame = aViewController.view.frame;
	spinner.frame = CGRectMake((overlayView.frame.size.width-spinner.frame.size.width)/2,
										overlayView.frame.size.height/2-spinner.frame.size.height,
										spinner.frame.size.width,
										spinner.frame.size.height);

	messageLabel.text = aMessage;
	messageLabel.frame = CGRectMake(20,
										overlayView.frame.size.height/2+10,
										overlayView.frame.size.width-40,
										60);

	[aViewController.view addSubview:overlayView];
}

- (void)hide {
	[overlayView removeFromSuperview];
}

@end
