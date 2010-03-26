//
//  NewsWebViewController.h
//  Ile sans fil
//
//  Created by Oli Kenobi on 09-10-11.
//  Copyright 2009 Kenobi Studios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView		*webView;
	UIActivityIndicatorView	*spinner;
	NSString						*_url;
}

@property (nonatomic, retain) NSString *url;

@end
