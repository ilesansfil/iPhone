//
//  NewsWebViewController.m
//  Ile sans fil
//
//  Created by Oli Kenobi on 09-10-11.
//  Copyright 2009 Kenobi Studios. All rights reserved.
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

	if (self.url) {
		NSURL *url = [NSURL URLWithString:self.url];
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		[webView loadRequest:requestObj];
	}
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


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[spinner startAnimating];
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	[spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	[spinner stopAnimating];
}

@end
