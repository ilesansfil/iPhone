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
#import "EGORefreshTableHeaderView.h"
#import "RootViewController.h"

#define kRSSURL @"http://www.ilesansfil.org/feed/"
#define kRSSURL2 @"http://twitter.com/statuses/user_timeline/16543294.rss"

@interface NewsViewController (Private)
- (void)dataSourceDidFinishLoadingNewData;

@end

@implementation NewsViewController
@synthesize stories,twitterStories,reloading=_reloading;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	isOffline=FALSE;
	
	
		
	
	[Switcher setTitle:NSLocalizedString(@"Blog",@"") forSegmentAtIndex:0];
	[Switcher setTitle:NSLocalizedString(@"Twitter",@"") forSegmentAtIndex:1];
	Switcher.frame=CGRectMake(30, 3, 250, 35);
		if([self isConnectionAvailable] == NO) {
			
			if([[News findAll] count] == 0) {

			[self setView:connectionView];
			[alertMain setText:NSLocalizedString(@"Cannot connect to the Internet", @"")];
			[alertMessage setText:NSLocalizedString(@"To take advantage of offline mode, you need to connect once to Internet to create the database of news.", @"")];
			}else {
				
				//Switcher.hidden=TRUE;
				[Switcher removeSegmentAtIndex:1 animated:NO];
				isOffline=TRUE;
				//self.navigationItem.title = NSLocalizedString(@"Blog", @"");
				stories=[[NSMutableArray alloc] init];
			
				[self setStories:[NSMutableArray arrayWithArray:[[Model shared] fetchObjectsForEntityForName:@"News" predicate:nil sortedBy:@"createdAt" ascending:NO limit:0]]];
				[newsTable reloadData];
			}

		} else {
			

	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
	

	activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activity.hidesWhenStopped = YES;
	[activity startAnimating];
	UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
	self.navigationItem.rightBarButtonItem = spinnerItem;
	
		
	
			
		
	NSInvocationOperation *	operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"1"];		
	
	[operationQueue addOperation:operation2];
	NSInvocationOperation *	operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"0"];
	
	[operationQueue addOperation:operation];
	

	[operation release];
	[operation2 release];
			
	}

	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = NSLocalizedString(@"ISF News", @"");
	
	[self updateBadge];

	
	
}

- (void)updateBadge {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *updateSuccess=[prefs stringForKey:@"updateSuccess"];
	
	if([UIApplication sharedApplication].applicationIconBadgeNumber!=0 | ![updateSuccess isEqualToString:@"success"])
	{
		NSLog(@"HOPHOPHOP ON RENTRE DEDANS");
		
		
		
#if !TARGET_IPHONE_SIMULATOR
		
		
		// Get Bundle Info for Remote Registration (handy if you have more than one app)
		NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
		NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		
		
		// Get the users Device Model, Display Name, Unique ID, Token & Version Number
		UIDevice *dev = [UIDevice currentDevice];
		NSString *deviceUuid = dev.uniqueIdentifier;
		NSString *deviceName = dev.name;
		NSString *deviceModel = dev.model;
		NSString *deviceSystemVersion = dev.systemVersion;
		
		
		// Prepare the Device Token for Registration (remove spaces and < >)
		
		NSString *deviceToken =[prefs stringForKey:@"deviceToken"];
		NSLog(@"token : %@ :",deviceToken);
		
		// Build URL String for Registration
		// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
		// !!! SAMPLE: "secure.awesomeapp.com"
		//NSString *host = @"auth.ilesansfil.org/authpuppy/cms/Push";
		NSString *numBadge=@"0";
		NSString *host = @"www.ilesansfil.org/wp-content/plugins/push-notification/";
		// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
		// !!! ( MUST START WITH / AND END WITH ? ). 
		// !!! SAMPLE: "/path/to/apns.php?"
		NSString *urlString = [NSString stringWithFormat:@"/20100713iphonescript.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&typeOp=update&numbadge=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion,numBadge];
		
		
		//NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&typeOp=update&numbadge=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion,numBadge];
		NSHTTPURLResponse *response = NULL;
		NSError *error = NULL;
		// Register the Device Data
		// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
		NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
		
		/* [request setHTTPMethod: @"POST"];
		 [request setHTTPBody:postData];
		 [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
		 [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];*/
		NSHTTPURLResponse *httpResponse;
		
		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSLog(@"Register error: %@", error);
		NSLog(@"Register response: %@", response);
		NSLog(@"Register URL: %@", url);
		NSLog(@"Return Data: %@", returnData);
		httpResponse = (NSHTTPURLResponse *)response;
		int statusCode = [httpResponse statusCode];  
		NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
		NSLog(@"HTTP Status code: %d", statusCode);
		
		if(statusCode>400 | statusCode==0)
		{
			[prefs setObject:@"notsuccess" forKey:@"updateSuccess"];
			[prefs synchronize];
		}else {
			[prefs setObject:@"success" forKey:@"updateSuccess"];
			[prefs synchronize];
			[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
			//[rootViewController changeNumberBadge:2:[NSString stringWithFormat:@"%d",[UIApplication sharedApplication].applicationIconBadgeNumber]];
			[rootViewController changeNumberBadge:2:NULL];
		}
		
		
		
		NSString *updateSuccess=[prefs stringForKey:@"updateSuccess"];
		NSLog(@"success : %@ :",updateSuccess);
		
#endif
		
		
	
}
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

	
	
	NSLog(@"stories array has %d items", [stories count]);
	
	NSLog(@"stories array has %d items", [twitterStories count]); 
	
	if(!isOffline) {
		if([Switcher selectedSegmentIndex]==1)
		{
			return [twitterStories count];
		
		}else {
			return [stories count];
		}
	}else{
		
		return [stories count];
		
	}
	

	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!isOffline) {
		
		if([Switcher selectedSegmentIndex]==1)
		{
			int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
			//NSString *text = [[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"];
				NSString *text = [[[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"] substringWithRange:NSMakeRange(5, [[[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"] length]-5)];
			CGFloat height = 26.0f + [text sizeWithFont:[UIFont systemFontOfSize:12] 
									  constrainedToSize:CGSizeMake(270, 9999) 
										  lineBreakMode:UILineBreakModeWordWrap].height;
			
			
			return height;
			
		}else {
			int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
			NSString *text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
			CGFloat height = 20.0f + [text sizeWithFont:[UIFont boldSystemFontOfSize:15] 
									  constrainedToSize:CGSizeMake(280, 2000) 
										  lineBreakMode:UILineBreakModeWordWrap].height;
			return MAX(height, 44.0f);
		}

			
		

	}else {
		int storyIndex = indexPath.row;
		NSString *text = [[stories objectAtIndex: storyIndex] title];
		CGFloat height = 20.0f + [text sizeWithFont:[UIFont boldSystemFontOfSize:15] 
								  constrainedToSize:CGSizeMake(280, 2000) 
									  lineBreakMode:UILineBreakModeWordWrap].height;
		return MAX(height, 44.0f);	
		
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	int storyIndex						= [indexPath indexAtPosition: [indexPath length] - 1];
	
	NSInteger pair = storyIndex % 2;
	if([Switcher selectedSegmentIndex]==1 && pair==0)
   {
	cell.backgroundColor = [UIColor colorWithRed:160.0/255 green:215.0/255 blue:246.0/255 alpha:0.1];
   }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!isOffline) {
		
		if([Switcher selectedSegmentIndex]==1)
		{
			static NSString *MyIdentifier = @"MyIdentifier";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
			int storyIndex						= [indexPath indexAtPosition: [indexPath length] - 1];
			
			UILabel *TitleLabel = nil;
			UILabel *dateLabel = nil;
			UILabel *DetailLabel = nil;
			UIImageView *Image = nil;
			
			
				
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
				
				TitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(46, 4, 138, 20)] autorelease];
				TitleLabel.tag = 2;
				TitleLabel.font = [UIFont boldSystemFontOfSize:18];
				TitleLabel.backgroundColor = [UIColor colorWithRed:159.0/255 green:215.0/255 blue:246.0/255 alpha:0];
				[cell.contentView addSubview:TitleLabel];
				
				dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(225, 5, 130, 10)] autorelease];
				dateLabel.tag = 3;
				dateLabel.font = [UIFont systemFontOfSize:10];
				dateLabel.backgroundColor = [UIColor colorWithRed:159.0/255 green:215.0/255 blue:246.0/255 alpha:0];
				[cell.contentView addSubview:dateLabel];
				
				DetailLabel = [[[UILabel alloc] initWithFrame:CGRectMake(46, 24, 270, 43)] autorelease];
				DetailLabel.tag = 4;
				DetailLabel.numberOfLines=4;
				DetailLabel.font = [UIFont systemFontOfSize:12];
				DetailLabel.backgroundColor = [UIColor colorWithRed:159.0/255 green:215.0/255 blue:246.0/255 alpha:0];
			//	DetailLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
				DetailLabel.lineBreakMode=UILineBreakModeWordWrap;
				DetailLabel.textAlignment=UITextAlignmentLeft;
				[cell.contentView addSubview:DetailLabel];
				
				Image = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconISF.png"]] autorelease];
				CGRect imageFrame = Image.frame;
				imageFrame.origin = CGPointMake(2, 2);
				Image.frame = imageFrame;
				Image.tag = 5;
				Image.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:Image];
				
				
				// A reusable cell was available, so we just need to get a reference to the subviews using their tags.
				TitleLabel = (UILabel *)[cell.contentView viewWithTag:2];
				dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
				DetailLabel = (UILabel *)[cell.contentView viewWithTag:4];
				Image = (UIImageView *)[cell.contentView viewWithTag:5];
			
		
			
			
		
			TitleLabel.text = [[[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"] substringWithRange:NSMakeRange(0, 3)];
				
			DetailLabel.text =  [[[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"] substringWithRange:NSMakeRange(5, [[[twitterStories objectAtIndex: storyIndex] objectForKey: @"title"] length]-5)];
					
			
			
			
			
			
			NSString *theDate=[[twitterStories objectAtIndex:storyIndex] objectForKey:@"date"];
			
			
			NSMutableString *TheFinalDate=[NSMutableString stringWithString:[theDate substringWithRange:NSMakeRange(5, 2)]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[NSString stringWithFormat:@"%d", [self ConvertMonth:[theDate substringWithRange:NSMakeRange(8,3)]]]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(12, 4)]];
			[TheFinalDate appendString:@" "];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(17, 8)]];
			
			NSDate *date=[self convertStringDate:TheFinalDate];
			
			NSLocale *locale = [NSLocale currentLocale];
			
			
			if([[locale localeIdentifier] isEqualToString:@"fr_FR"])
			{
				
				// Create date formatter
				NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
				[dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
				
				// Set the locale as needed in the formatter (this example uses Japanese)
				[dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] autorelease]];
				
				// Create date string from formatter, using the current date
				NSString *dateString = [dateFormat stringFromDate:date];  
				
				// We're done with this now
				[dateFormat release];
				dateLabel.text = [[NSString stringWithFormat:@"%@",dateString] substringWithRange:NSMakeRange(0,[[NSString stringWithFormat:@"%@",dateString] length]-3)];
				
				
			}else {
				dateLabel.text=[[[NSString stringWithFormat:@"%@",theDate] stringByReplacingOccurrencesOfString:@" +0000" withString:@""] substringWithRange:NSMakeRange(4,[[[NSString stringWithFormat:@"%@",theDate] stringByReplacingOccurrencesOfString:@" +0000" withString:@""] length]-12)];
				
			}
			
			
			cell.detailTextLabel.font		= [UIFont systemFontOfSize:12];
			return cell;
			
			
		}else {
			static NSString *MyIdentifier = @"MyIdentifier";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			
			int storyIndex						= [indexPath indexAtPosition: [indexPath length] - 1];
			cell.textLabel.text				= [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
			if([Switcher selectedSegmentIndex]==1)
			{
				cell.textLabel.font 				= [UIFont systemFontOfSize:12];
			}else {
				cell.textLabel.font 				= [UIFont boldSystemFontOfSize:15];
			}
			cell.textLabel.numberOfLines 	= 0;
			
			
			
			
			
			
			NSString *theDate=[[stories objectAtIndex:storyIndex] objectForKey:@"date"];
			
			
			NSMutableString *TheFinalDate=[NSMutableString stringWithString:[theDate substringWithRange:NSMakeRange(5, 2)]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[NSString stringWithFormat:@"%d", [self ConvertMonth:[theDate substringWithRange:NSMakeRange(8,3)]]]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(12, 4)]];
			[TheFinalDate appendString:@" "];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(17, 8)]];
			
			NSDate *date=[self convertStringDate:TheFinalDate];
			
			NSLocale *locale = [NSLocale currentLocale];
			
			
			if([[locale localeIdentifier] isEqualToString:@"fr_FR"])
			{
				
				// Create date formatter
				NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
				[dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
				
				// Set the locale as needed in the formatter (this example uses Japanese)
				[dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] autorelease]];
				
				// Create date string from formatter, using the current date
				NSString *dateString = [dateFormat stringFromDate:date];  
				
				// We're done with this now
				[dateFormat release];
				
				cell.detailTextLabel.text=[[NSString stringWithFormat:@"%@",dateString] substringWithRange:NSMakeRange(0,[[NSString stringWithFormat:@"%@",dateString] length]-3)];
				
			}else {
				
				cell.detailTextLabel.text=[[[NSString stringWithFormat:@"%@",theDate] stringByReplacingOccurrencesOfString:@" +0000" withString:@""] substringWithRange:NSMakeRange(0,[[[NSString stringWithFormat:@"%@",theDate] stringByReplacingOccurrencesOfString:@" +0000" withString:@""] length]-6)];
			}
			
			
			cell.detailTextLabel.font		= [UIFont systemFontOfSize:12];
			return cell;
			
			
		}

	
	
		
		
	}else {
		
		static NSString *MyIdentifier = @"MyIdentifier";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		int storyIndex						=indexPath.row;
		cell.textLabel.text				= [[stories objectAtIndex: storyIndex] title];
		cell.textLabel.font 				= [UIFont boldSystemFontOfSize:15];
		cell.textLabel.numberOfLines 	= 0;
		
		
		NSDate *date=[[stories objectAtIndex:storyIndex] createdAt];
		
		
		NSLocale *locale = [NSLocale currentLocale];
		
		
		if([[locale localeIdentifier] isEqualToString:@"fr_FR"])
		{
			
			// Create date formatter
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			
			// Set the locale as needed in the formatter (this example uses Japanese)
			[dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] autorelease]];
			
			// Create date string from formatter, using the current date
			NSString *dateString = [dateFormat stringFromDate:date];  
			
			// We're done with this now
			[dateFormat release];
			
						
			cell.detailTextLabel.text=[[NSString stringWithFormat:@"%@",dateString] substringWithRange:NSMakeRange(0,[[NSString stringWithFormat:@"%@",dateString] length]-3)];
			
		}else {
			
			cell.detailTextLabel.text=[[NSString stringWithFormat:@"%@",date] substringWithRange:NSMakeRange(0,[[NSString stringWithFormat:@"%@",date] length]-3)];
		}
		
			cell.detailTextLabel.font		= [UIFont systemFontOfSize:12];	
		return cell;
	}
	


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!isOffline) {
		
		

		int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
		NSString * storyLink;
		if([Switcher selectedSegmentIndex]==1)
		{
			storyLink = [[twitterStories objectAtIndex: storyIndex] objectForKey: @"link"];
		}else {
			storyLink = [[stories objectAtIndex: storyIndex] objectForKey: @"link"];
		}
		
	
		// clean up the link - get rid of spaces, returns, and tabs...
		storyLink = [storyLink stringByReplacingOccurrencesOfString:@" " withString:@""];
		storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		storyLink = [storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""];
	
		NSLog(@"link: %@", storyLink);

		NewsWebViewController *webViewController = [[NewsWebViewController alloc] initWithNibName:@"NewsWebViewController" bundle:nil];
		[webViewController setUrl:storyLink];
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
		
	}else {
		
		
		int storyIndex = indexPath.row;
		
	
		NewsWebViewController *webViewController = [[NewsWebViewController alloc] initWithNibName:@"NewsWebViewController" bundle:nil];
	
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path = [mainBundle bundlePath];


		
		NSString *filePath = [mainBundle pathForResource:@"html1" ofType:@"html"];
		NSStringEncoding encoding;
		NSError *error;
		NSString *fileContents = [[[NSString alloc] initWithContentsOfFile:filePath
															  usedEncoding:&encoding
																	 error:&error]
								  autorelease];
		//NSLog(@"CONTENU HTML1 %@ :",fileContents);
		NSString *HtmlCode=[fileContents stringByAppendingString:[[stories objectAtIndex: storyIndex] title]];
		
		filePath = [mainBundle pathForResource:@"html2" ofType:@"html"];
		fileContents = [[[NSString alloc] initWithContentsOfFile:filePath
													usedEncoding:&encoding
														   error:&error]
						autorelease];
		
		
		HtmlCode=[HtmlCode stringByAppendingString:fileContents];
		NSString *date=[NSString stringWithFormat:@"%@",[[stories objectAtIndex:storyIndex] createdAt]];
		HtmlCode=[HtmlCode stringByAppendingString:[NSString stringWithFormat:@"%@",[date substringWithRange:NSMakeRange(0,[date length]-5)]]];
		
		filePath = [mainBundle pathForResource:@"html3" ofType:@"html"];
		fileContents = [[[NSString alloc] initWithContentsOfFile:filePath
													usedEncoding:&encoding
														   error:&error]
						autorelease];
		HtmlCode=[HtmlCode stringByAppendingString:fileContents];
		HtmlCode=[HtmlCode stringByAppendingString:[NSString stringWithFormat:@"%@",[[stories objectAtIndex:storyIndex] text]]];

		filePath = [mainBundle pathForResource:@"html4" ofType:@"html"];
		fileContents = [[[NSString alloc] initWithContentsOfFile:filePath
													usedEncoding:&encoding
														   error:&error]
						autorelease];
		HtmlCode=[HtmlCode stringByAppendingString:fileContents];

		
		[webViewController setContentWebView:HtmlCode:path];
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];

		
	}

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

-(void) segmentAction:(id)sender {
	
	NSLog(@"onglet select %d :",[sender selectedSegmentIndex]);
	
		//Switcher.enabled=FALSE;
	/*	operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
		
		//refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
		//self.navigationItem.leftBarButtonItem = refreshButton;
		
		activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activity.hidesWhenStopped = YES;
		[activity startAnimating];
		UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
		self.navigationItem.rightBarButtonItem = spinnerItem;
		NSInvocationOperation *operation;
		if([sender selectedSegmentIndex]==1)
		{
			operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtURL:) object:kRSSURL2];
		}else {
			operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtURL:) object:kRSSURL];
		}

		
		[operationQueue addOperation:operation];
		[operation release];
		
	
	
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}*/
	
	[self.tableView reloadData];
		
		
	
}

#pragma mark -
#pragma mark XML Parser

- (IBAction)refresh {
	
//	self.navigationItem.leftBarButtonItem = nil; 
	Switcher.enabled=FALSE;
	stories=[[NSMutableArray alloc] init];
	[self.tableView reloadData];
	[activity startAnimating];
	NSInvocationOperation *operation;
	if([Switcher selectedSegmentIndex]==1)
	{
		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"1"];
	}else {

		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"0"];
	}
	[operationQueue addOperation:operation];
	[operation release];
	

	
	
}
-(void)parseXMLFileAtNumberTypeNews:(NSString *)Number{
	
	
	if([Number isEqualToString:@"1"])
	{
	
		NewsTypeNumber=1;
		if (twitterStories) [twitterStories removeAllObjects];
		else twitterStories = [[NSMutableArray alloc] init];
	[self parseXMLFileAtURL:kRSSURL2];
	}else {
		
		NewsTypeNumber=0;
		if (stories) [stories removeAllObjects];
		else stories = [[NSMutableArray alloc] init];
	[self parseXMLFileAtURL:kRSSURL];	
	}

}
- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL {	
	
	
	
	[self.tableView reloadData];
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
	Switcher.enabled=TRUE;
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
		[item setObject:currentText forKey:@"text"];
		[item setObject:currentDate forKey:@"date"];
		
		if(NewsTypeNumber==1)
		{
			[twitterStories addObject:[[item copy] autorelease]];
			//NSLog(@"C LE 1 ajout et yen a %d :",[twitterStories count]);
			
		}else {
			[stories addObject:[[item copy] autorelease]];
			//NSLog(@"C LE 0 ajout et yen a %d :",[stories count]);
			
		}

		

		NSLog(@"adding story: %@", currentTitle);
	}
	
}
-(NSInteger) ConvertMonth:(NSString *) Month {
	
	NSArray *month = [[NSArray alloc] initWithObjects:@"Jan", @"Feb", @"Mar", @"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil];
	NSInteger num=0;
	while (num<[month count]) {
		if([Month isEqualToString:[month objectAtIndex:num]])
		{
			return num+1;
			
		}else {
			num++;
		}
		
	}
	return num;
}
- (NSDate *) convertStringDate:(NSString *) convertString {
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease]; 
	// format dd-MM-yyyy 
	[df setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] autorelease]; 
	[df setLocale:locale];
	NSString *texteString = [[[NSString alloc] initWithFormat:@"%@ 12:00:00",convertString] autorelease];
	NSDate *dateReturn = [[[NSDate alloc] init] autorelease]; 
	dateReturn = [df dateFromString:texteString]; 
	if (dateReturn == NULL) {
	// format dd MM yyyy
	[df setDateFormat:@"dd MM yyyy HH:mm:ss"];
	texteString = [[[NSString alloc] initWithFormat:@"%@ 12:00:00",convertString] autorelease];
	dateReturn = [df dateFromString:texteString]; 
	}
	//NSLog(@"DATE  %@ ",texteString);
		return dateReturn;
	
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
	} else if ([currentElement isEqualToString:@"content:encoded"]) {
		[currentText appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	
	if(NewsTypeNumber!=1)
	{
		NSInteger num=0;
		News *news;
		[[Model shared] deleteObjects:[News findAll]];
		[[Model shared] save];
		while(num<[stories count])
		{
		
		
			news = [[Model shared] insertNewObjectForEntityForName:@"News"];
			//news=(News *)[stories objectAtIndex:num];
			news.identifier=[NSString stringWithFormat:@"%d", num];
		
			news.title=[[stories objectAtIndex:num] objectForKey:@"title"];
			news.text=[[stories objectAtIndex:num] objectForKey:@"text"];
			news.link=[[stories objectAtIndex:num] objectForKey:@"link"];
		
		
			news.summary=[[stories objectAtIndex:num] objectForKey:@"summary"];
			//@"dd-MM-yyyy HH:mm:ss"]
			NSString *theDate=[[stories objectAtIndex:num] objectForKey:@"date"];
			//Mon, 14 Dec 2009 11:32:44 +0000
		
			//NSString *TheFinalDate=[theDate substringFromIndex:5];
			NSMutableString *TheFinalDate=[NSMutableString stringWithString:[theDate substringWithRange:NSMakeRange(5, 2)]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[NSString stringWithFormat:@"%d", [self ConvertMonth:[theDate substringWithRange:NSMakeRange(8,3)]]]];
			[TheFinalDate appendString:@"-"];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(12, 4)]];
			[TheFinalDate appendString:@" "];
			[TheFinalDate appendString:[theDate substringWithRange:NSMakeRange(17, 8)]];
		 
			//NSLog(@"DATE  %@ ",TheFinalDate);
		 
			[news setCreatedAt:[self convertStringDate:TheFinalDate]];

	
			[[Model shared] save];
		
		
			num++;
		}
	}
	
//	NSLog(@"IL Y A  %d NEWSSS", [lesnews count]);
	
	[activity stopAnimating];
	Switcher.enabled=TRUE;
	
	NSLog(@"all done!");
	if(NewsTypeNumber==1)
	{
		NSLog(@"stories array has %d items", [twitterStories count]);
	}else {
		NSLog(@"stories array has %d items", [stories count]);
	}

	
	[self.tableView reloadData];
	
	//refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	//self.navigationItem.leftBarButtonItem = refreshButton;
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


- (void)reloadTableViewDataSource{
	
	
	Switcher.enabled=FALSE;
	[activity startAnimating];
	NSInvocationOperation *operation;
	if([Switcher selectedSegmentIndex]==1)
	{
		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"1"];
	}else {
		
		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseXMLFileAtNumberTypeNews:) object:@"0"];
	}	
	[operationQueue addOperation:operation];
	[operation release];
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:4.0];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

@end

