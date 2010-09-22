//
//  googleMapsAPI.m
//  Ile sans fil
//
//  Created by Oli on 07/20/09.
//  Copyright 2009 Kolt Production. License Apache2
//

#import "googleMapsAPI.h"
#import "ISFAppDelegate.h"


NSString *const gMaps_API_Key = @"ABQIAAAAov9lIFBKpvUDvAl8bSGlxxQbGtJ3edm477Vb4vswub_Iw0bmdhQ6MsM4-jxhrN_HaQTCZ6Ro6sa-9A";


@implementation googleMapsAPI

@synthesize delegate;

- (void)getCoordFromAddress:(NSString *)address {
	currentMethod = kGoogleMapsMethodGetCoordFromAddress;

	// Create the query and retrieve the address
	NSString *tmpAddress = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv&oe=utf8&sensor=false&key=%@", tmpAddress, gMaps_API_Key];
	NSURL *url = [NSURL URLWithString:urlString];
	[[ISFAppDelegate appDelegate] showNetworkActivity:YES];
	NSString *csvString = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
	[[ISFAppDelegate appDelegate] showNetworkActivity:NO];

	// Parse the result
	NSArray *results = [csvString componentsSeparatedByString:@","];
	if([[results objectAtIndex:0] intValue] != 200) {
		[delegate googleMapsAPIDidFailWithMessage:NSLocalizedString(@"Could not find the address", @"")];
		return;
	}
	
	// Retrieve the coordinates
	CLLocationCoordinate2D coords;
	coords.latitude = [[results objectAtIndex:2] floatValue];
	coords.longitude = [[results objectAtIndex:3] floatValue];

	// Notify the delegate
	[delegate googleMapsAPIDidFindCoordinates:coords];
}

@end
