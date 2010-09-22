//
//  NewsWebViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import <UIKit/UIKit.h>


@interface NewsWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView		*webView;
	UIActivityIndicatorView	*spinner;
	NSString						*_url;
}

@property (nonatomic, retain) NSString *url;

@end
