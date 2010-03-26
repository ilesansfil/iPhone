//
//  NewsViewController.h
//  Ile sans fil
//
//  Created by Oli Kenobi on 09-10-10.
//  Copyright 2009 Kenobi Studios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsViewController : UITableViewController {
	IBOutlet UITableView		*newsTable;
	UIActivityIndicatorView *activity;
	CGSize						 cellSize;
	NSXMLParser					*rssParser;
	NSMutableArray				*stories;
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink;

	NSOperationQueue *operationQueue;
}

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)refresh;

@end
