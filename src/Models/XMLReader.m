//
//  XMLReader.m
//  Ile sans fil
//
//  Created by Oli on 24/05/09.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import "XMLReader.h"
#import "Model.h"
#import "Hotspot.h"
#import "Node.h"
#import "ISFAppDelegate.h"


// XML tags - Hotspot
#define XML_TAG_HOTSPOTID			@"hotspotId"
#define XML_TAG_NAME					@"name"
#define XML_TAG_OPENINGDATE		@"openingDate"
#define XML_TAG_WEBSITEURL			@"webSiteUrl"
#define XML_TAG_DESCRIPTION		@"description"
#define XML_TAG_MASSTRANSITINFO	@"massTransitInfo"
#define XML_TAG_CONTACTEMAIL		@"contactEmail"
#define XML_TAG_CONTACTPHONE		@"contactPhoneNumber"
#define XML_TAG_CIVICNUMBER		@"civicNumber"
#define XML_TAG_STREETADDRESS		@"streetAddress"
#define XML_TAG_CITY					@"city"
#define XML_TAG_PROVINCE			@"province"
#define XML_TAG_POSTALCODE			@"postalCode"
#define XML_TAG_COUNTRY				@"country"
#define XML_TAG_HOTSPOTLATLONG	@"gisCenterLatLong"
#define XML_TAG_HOTSPOT_LAT		@"lat"
#define XML_TAG_HOTSPOT_LONG		@"long"

// XML tags - Node
#define XML_TAG_NODEID				@"nodeId"
#define XML_TAG_CREATIONDATE		@"creationDate"
#define XML_TAG_STATUS				@"status"
#define XML_TAG_NODELATLONG		@"gisLatLong"
#define XML_TAG_NODE_LAT			@"lat"
#define XML_TAG_NODE_LONG			@"long"

static NSUInteger parsedLocationsCounter;

@implementation XMLReader

@synthesize delegate;


- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error {	

	NSURLRequest *theRequest=[NSURLRequest requestWithURL:URL
															cachePolicy:NSURLRequestUseProtocolCachePolicy
													  timeoutInterval:60.0];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
	[ISFAppDelegate appDelegate].isLoadingData = YES;
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[ISFAppDelegate appDelegate].isLoadingData = NO;
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	// release the connection, and the data object
	[connection release];
	// receivedData is declared as a method instance elsewhere
	[receivedData release];
	
	// inform the user
	NSLog(@"Connection failed! Error - %@ %@",
			[error localizedDescription],
			[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[ISFAppDelegate appDelegate].isLoadingData = NO;
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	[self startParsing];
	
	[connection release];
	[receivedData release];
}


#pragma mark -
#pragma mark XML Parser

- (void)startParsing {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	hotspotsList = [[NSMutableArray alloc] init];
	
	[parser parse];
		
	[parser release];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	parsedLocationsCounter 	= 0;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (qName) {
		elementName = qName;
	}

	// New hotspot
	if ([elementName isEqualToString:@"hotspot"]) {
		parsedLocationsCounter++;
		contentOfCurrentHotspot = [NSMutableDictionary dictionary];
		return;
	}
	
	// Nodes
	if ([elementName isEqualToString:@"nodes"]) {
		nodesForCurrentHotspot = [NSMutableArray array];
		return;
	}
	
	// New node
	if ([elementName isEqualToString:@"node"]) {
		contentOfCurrentNode	= [NSMutableDictionary dictionary];
		return;
	}
	
	// Hotspot properties
	if ([elementName isEqualToString:XML_TAG_HOTSPOTID] ||
		 [elementName isEqualToString:XML_TAG_NAME] ||
		 [elementName isEqualToString:XML_TAG_OPENINGDATE] ||
		 [elementName isEqualToString:XML_TAG_WEBSITEURL] ||
		 [elementName isEqualToString:XML_TAG_DESCRIPTION] ||
		 [elementName isEqualToString:XML_TAG_MASSTRANSITINFO] ||
		 [elementName isEqualToString:XML_TAG_CONTACTEMAIL] ||
		 [elementName isEqualToString:XML_TAG_CONTACTPHONE] ||
		 [elementName isEqualToString:XML_TAG_CIVICNUMBER] ||
		 [elementName isEqualToString:XML_TAG_STREETADDRESS] ||
		 [elementName isEqualToString:XML_TAG_CITY] ||
		 [elementName isEqualToString:XML_TAG_PROVINCE] ||
		 [elementName isEqualToString:XML_TAG_POSTALCODE] ||
		 [elementName isEqualToString:XML_TAG_COUNTRY]) contentOfCurrentLocationProperty = [NSMutableString string];
	
	else if ([elementName isEqualToString:XML_TAG_HOTSPOTLATLONG]) {
		[contentOfCurrentHotspot setObject:[attributeDict objectForKey:XML_TAG_HOTSPOT_LAT] forKey:XML_TAG_HOTSPOT_LAT];
		[contentOfCurrentHotspot setObject:[attributeDict objectForKey:XML_TAG_HOTSPOT_LONG] forKey:XML_TAG_HOTSPOT_LONG];
	}
	
	// Node properties
	else if ([elementName isEqualToString:XML_TAG_NODEID] ||
		 [elementName isEqualToString:XML_TAG_CREATIONDATE] ||
		 [elementName isEqualToString:XML_TAG_STATUS]) contentOfCurrentLocationProperty = [NSMutableString string];
	
	else if ([elementName isEqualToString:XML_TAG_NODELATLONG]) {
		[contentOfCurrentNode setObject:[attributeDict objectForKey:XML_TAG_NODE_LAT] forKey:XML_TAG_NODE_LAT];
		[contentOfCurrentNode setObject:[attributeDict objectForKey:XML_TAG_NODE_LONG] forKey:XML_TAG_NODE_LONG];
	}

	else contentOfCurrentLocationProperty = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
	if (qName) {
		elementName = qName;
	}
	
	// New hotspot
	if ([elementName isEqualToString:@"hotspot"]) {
		NSMutableDictionary *spot = [[NSMutableDictionary alloc] init];
		[spot setObject:contentOfCurrentHotspot forKey:@"hotspot"];
		[spot setObject:nodesForCurrentHotspot forKey:@"nodes"];
		[hotspotsList addObject:spot];
		[spot release];

		return;
	}
	
	// Node
	if ([elementName isEqualToString:@"node"]) {
		[nodesForCurrentHotspot addObject:contentOfCurrentNode];
		return;
	}

	// Hotspot properties
	if ([elementName isEqualToString:XML_TAG_HOTSPOTID] ||
		 [elementName isEqualToString:XML_TAG_NAME] ||
		 [elementName isEqualToString:XML_TAG_OPENINGDATE] ||
		 [elementName isEqualToString:XML_TAG_WEBSITEURL] ||
		 [elementName isEqualToString:XML_TAG_DESCRIPTION] ||
		 [elementName isEqualToString:XML_TAG_MASSTRANSITINFO] ||
		 [elementName isEqualToString:XML_TAG_CONTACTEMAIL] ||
		 [elementName isEqualToString:XML_TAG_CONTACTPHONE] ||
		 [elementName isEqualToString:XML_TAG_CIVICNUMBER] ||
		 [elementName isEqualToString:XML_TAG_STREETADDRESS] ||
		 [elementName isEqualToString:XML_TAG_CITY] ||
		 [elementName isEqualToString:XML_TAG_PROVINCE] ||
		 [elementName isEqualToString:XML_TAG_POSTALCODE] ||
		 [elementName isEqualToString:XML_TAG_COUNTRY]) [contentOfCurrentHotspot setObject:[contentOfCurrentLocationProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
	
	// Node properties
	if ([elementName isEqualToString:XML_TAG_NODEID] ||
		 [elementName isEqualToString:XML_TAG_CREATIONDATE] ||
		 [elementName isEqualToString:XML_TAG_STATUS]) [contentOfCurrentNode setObject:[contentOfCurrentLocationProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (contentOfCurrentLocationProperty) {
		[contentOfCurrentLocationProperty appendString:string];
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
//	[[Model shared] wipe];
	for (NSDictionary *spot in hotspotsList) {
		contentOfCurrentHotspot = [spot objectForKey:@"hotspot"];
		nodesForCurrentHotspot	= [spot objectForKey:@"nodes"];
	
		if(![(NSString *)[contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOT_LAT] isEqualToString:@""] & ![(NSString *)[contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOT_LONG] isEqualToString:@""])
		{		

	
//		Hotspot *hotspot = [[Model shared] insertNewObjectForEntityForName:@"Hotspot"];
		Hotspot *hotspot = [[Model shared] findOrCreateObjectForEntityForName:@"Hotspot" withIdentifier:[contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOTID]];
		if (hotspot.hotspotId == nil) {
			hotspot.hotspotId = [contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOTID];
			hotspot.createdAt = [NSDate date];
		}
		hotspot.city					= [contentOfCurrentHotspot objectForKey:XML_TAG_CITY];
		hotspot.civicNumber			= [contentOfCurrentHotspot objectForKey:XML_TAG_CIVICNUMBER];
		hotspot.contactEmail			= [contentOfCurrentHotspot objectForKey:XML_TAG_CONTACTEMAIL];
		hotspot.contactPhoneNumber	= [contentOfCurrentHotspot objectForKey:XML_TAG_CONTACTPHONE];
		hotspot.country				= [contentOfCurrentHotspot objectForKey:XML_TAG_COUNTRY];
		hotspot.massTransitInfo		= [contentOfCurrentHotspot objectForKey:XML_TAG_MASSTRANSITINFO];
		hotspot.name					= [contentOfCurrentHotspot objectForKey:XML_TAG_NAME];
		hotspot.openingDate			= [contentOfCurrentHotspot objectForKey:XML_TAG_OPENINGDATE];
		hotspot.postalCode			= [contentOfCurrentHotspot objectForKey:XML_TAG_POSTALCODE];
		hotspot.province				= [contentOfCurrentHotspot objectForKey:XML_TAG_PROVINCE];
		hotspot.streetAddress		= [contentOfCurrentHotspot objectForKey:XML_TAG_STREETADDRESS];
		hotspot.websiteUrl			= [contentOfCurrentHotspot objectForKey:XML_TAG_WEBSITEURL];
		hotspot.latitude				= [NSNumber numberWithDouble:[(NSString *)[contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOT_LAT] doubleValue]];
		hotspot.longitude				= [NSNumber numberWithDouble:[(NSString *)[contentOfCurrentHotspot objectForKey:XML_TAG_HOTSPOT_LONG] doubleValue]];
		hotspot.updatedAt 			= [NSDate date];
		
		// Add / Update nodes
		for (NSDictionary *nodeContent in nodesForCurrentHotspot) {
//			Node *node = [[Model shared] insertNewObjectForEntityForName:@"Node"];
			Node *node = [[Model shared] findOrCreateObjectForEntityForName:@"Node" withIdentifier:[nodeContent objectForKey:XML_TAG_NODEID]];
			if (node.nodeId == nil) {
				node.nodeId		= [nodeContent objectForKey:XML_TAG_NODEID];
				node.createdAt	= [NSDate date];
			}
			node.creationDate	= [nodeContent objectForKey:XML_TAG_CREATIONDATE];
			node.status			= [nodeContent objectForKey:XML_TAG_STATUS];
			node.latitude		= [NSNumber numberWithDouble:[(NSString *)[nodeContent objectForKey:XML_TAG_NODE_LAT] doubleValue]];
			node.longitude		= [NSNumber numberWithDouble:[(NSString *)[nodeContent objectForKey:XML_TAG_NODE_LONG] doubleValue]];
			node.updatedAt		= [NSDate date];
			node.hotspot 		= hotspot;
		}
			
		}
	}
	
	
	[[Model shared] save];
	if (delegate && [delegate respondsToSelector:@selector(XMLReaderDidFinishParsing)]) [delegate XMLReaderDidFinishParsing];
//	NSLog(@"%@", [Hotspot findAll]);
}

@end

