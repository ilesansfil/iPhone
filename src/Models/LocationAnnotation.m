//
//  Location.m
//  Ile sans fil
//
//  Created by Oli on 12/06/09.
//  Copyright 2009 Kolt Production. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

@synthesize coordinate, title, subtitle, shortname, hotspot;

- (void)dealloc {
	[title release];
	[subtitle release];
	[shortname release];
	[hotspot release];
	[super dealloc];
}

@end
