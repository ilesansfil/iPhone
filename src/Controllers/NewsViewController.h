//
//  NewsViewController.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import <UIKit/UIKit.h>

@class EGORefreshTableHeaderView;

@interface NewsViewController : UITableViewController {
	IBOutlet UITableView		*newsTable;
	UIActivityIndicatorView *activity;
	CGSize						 cellSize;
	NSXMLParser					*rssParser;
	NSMutableArray				*stories;
	IBOutlet UIView							*connectionView;
	IBOutlet UILabel						*alertMain;
	IBOutlet UILabel						*alertMessage;
	BOOL									isOffline;
	UIBarButtonItem *refreshButton;
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink, *currentAutor, *currentText;

	EGORefreshTableHeaderView *refreshHeaderView;
	
	NSOperationQueue *operationQueue;
	
	BOOL _reloading;
}
@property (nonatomic, retain) NSMutableArray *stories;
@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)refresh;
- (BOOL)isConnectionAvailable;
-(NSInteger) ConvertMonth:(NSString *) Month;
- (NSDate *) convertStringDate:(NSString *) convertString;
@end
