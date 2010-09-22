//
//  NewsViewController.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import "NewsViewController.h"
#import "NewsWebViewController.h"
#import "ISFAppDelegate.h"
#import "News.h"
#import "Model.h"

#define kRSSURL @"http://www.ilesansfil.org/feed/"

@implementation NewsViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	
	

		if([self isConnectionAvailable] == NO) {
			[self setView:connectionView];
			[alertMain setText:NSLocalizedString(@"Cannot connect to the Internet", @"")];
			[alertMessage setText:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network to view the news.", @"")];
			
		} else {
			

	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
	
	//refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	//self.navigationItem.leftBarButtonItem = refreshButton;

	activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activity.hidesWhenStopped = YES;
	[activity startAnimating];
	UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
	self.navigationItem.rightBarButtonItem = spinnerItem;
	
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtURL:) object:kRSSURL];
	[operationQueue addOperation:operation];
	[operation release];
			
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = NSLocalizedString(@"ISF News", @"");
}

 
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	NSString *text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	CGFloat height = 20.0f + [text sizeWithFont:[UIFont boldSystemFontOfSize:15] 
									  constrainedToSize:CGSizeMake(280, 2000) 
											lineBreakMode:UILineBreakModeWordWrap].height;
	return MAX(height, 44.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	int storyIndex						= [indexPath indexAtPosition: [indexPath length] - 1];
	cell.textLabel.text				= [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	cell.textLabel.font 				= [UIFont boldSystemFontOfSize:15];
	cell.textLabel.numberOfLines 	= 0;
	cell.detailTextLabel.text		= [[[stories objectAtIndex:storyIndex] objectForKey: @"date"] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
	cell.detailTextLabel.font		= [UIFont systemFontOfSize:12];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	
	NSString * storyLink = [[stories objectAtIndex: storyIndex] objectForKey: @"link"];
	
	// clean up the link - get rid of spaces, returns, and tabs...
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@" " withString:@""];
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""];
	
	NSLog(@"link: %@", storyLink);

	NewsWebViewController *webViewController = [[NewsWebViewController alloc] initWithNibName:@"NewsWebViewController" bundle:nil];
	[webViewController setUrl:storyLink];
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}


- (void)dealloc {
	[currentElement release];
	[rssParser release];
	[stories release];
	[item release];
	[currentTitle release];
	[currentDate release];
	[currentSummary release];
	[currentLink release];
	[activity release];
	[super dealloc];
}


#pragma mark -
#pragma mark XML Parser

- (IBAction)refresh {
	
	self.navigationItem.leftBarButtonItem = nil; 
	
	stories=[[NSMutableArray alloc] init];
	[self.tableView reloadData];
	[activity startAnimating];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtURL:) object:kRSSURL];
	[operationQueue addOperation:operation];
	[operation release];
	

	
	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	if (stories) [stories removeAllObjects];
	else stories = [[NSMutableArray alloc] init];
	
	//you must then convert the path to a proper NSURL or it won't work
	NSURL *xmlURL = [NSURL URLWithString:URL];
	
	// here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
	// this may be necessary only for the toolchain
	if (rssParser) {
		[rssParser release];
		rssParser = nil;
	}
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[rssParser setDelegate:self];
	
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
	
	[rssParser parse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	[activity stopAnimating];
	
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	//NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentAutor = [[NSMutableString alloc] init];
		currentText = [[NSMutableString alloc] init];

	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
		
		[stories addObject:[[item copy] autorelease]];
		
		/*
		News *news = [[Model shared] insertNewObjectForEntityForName:@"News"];

		news.title=[item objectForKey:@"title"];
		news.link=[item objectForKey:@"link"];
		news.summary=[item objectForKey:@"summary"];
		news.createdAt=[item objectForKey:@"date"];
//		news.text=[item objectForKey:@"title"];
	//	news.title=[item objectForKey:@"title"];

		
		
		
		[[Model shared] save];*/
		NSLog(@"adding story: %@", currentTitle);
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[activity stopAnimating];
	
	
	NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);
	[self.tableView reloadData];
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.leftBarButtonItem = refreshButton;
}
- (BOOL)isConnectionAvailable {
	static BOOL checkNetwork = YES;
	static BOOL available = NO;
	if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
		checkNetwork = NO;
		
		Boolean success;    
		const char *host_name = "google.com";
		
		SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
		SCNetworkReachabilityFlags flags;
		success = SCNetworkReachabilityGetFlags(reachability, &flags);
		available = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
		CFRelease(reachability);
	}
	return available;
}


@end

