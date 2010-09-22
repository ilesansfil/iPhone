//
//  NewsWebViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "NewsWebViewController.h"
#import "ISFAppDelegate.h"


@implementation NewsWebViewController

@synthesize url = _url;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.hidesWhenStopped = YES;
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	self.navigationItem.rightBarButtonItem = item;
	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.url && !contentWebView) {
		NSURL *url = [NSURL URLWithString:self.url];
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		[webView loadRequest:requestObj];
	} else {
	
		[webView loadHTMLString:contentWebView baseURL:[NSURL fileURLWithPath:self.url]];
		[webView reload];
		}
	

	
	
	//NSLog(@"CONTENU AFFICHER : %@",[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	if (webView.loading) {
		[webView stopLoading];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	webView = nil;
}


- (void)dealloc {
	webView.delegate = nil;
	[webView release];
	[super dealloc];
}
- (void)setContentWebView:(NSString *)content:(NSString *)URL {
	

	contentWebView=content;
	self.url=URL;

}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[spinner startAnimating];
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	[spinner stopAnimating];
	//NSLog(@"CONTENU AFFICHER : %@",[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	[spinner stopAnimating];
}

@end
