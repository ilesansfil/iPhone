// 
//  Hotspot.m
//  Ile sans fil
//
//  Created by Oli on 09-10-04.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import "Hotspot.h"
#import "Model.h"
#import "Node.h"


@implementation Hotspot 

@dynamic civicNumber;
@dynamic updatedAt;
@dynamic createdAt;
@dynamic contactPhoneNumber;
@dynamic streetAddress;
@dynamic longitude;
@dynamic massTransitInfo;
@dynamic latitude;
@dynamic hotspotId;
@dynamic openingDate;
@dynamic province;
@dynamic city;
@dynamic postalCode;
@dynamic websiteUrl;
@dynamic country;
@dynamic name;
@dynamic contactEmail;
@dynamic nodes;


+ (Hotspot *)findOrCreateContactWithIdentifier:(NSString *)identifier {
	return [[Model shared] findOrCreateObjectForEntityForName:@"Hotspot" withIdentifier:identifier];
}


+ (NSArray *)findAll {
	return [[Model shared] fetchObjectsForEntityForName:@"Hotspot" 
															predicate:nil 
															 sortedBy:@"createdAt"
																ascending:YES
																 limit:0];
}

- (HotspotStatus)status {
	HotspotStatus status = kHotspotStatusUnknow;
	
	for (Node *node in [self nodes]) {
		if (status == kHotspotStatusUnknow && [node.status isEqualToString:@"down"]) status = kHotspotStatusDown;
		if ([node.status isEqualToString:@"up"]) return kHotspotStatusUp;
	}
	
	return status;
}

- (NSString *)fullAddressOneLine {
	NSMutableString *address = [[[NSMutableString alloc] init] autorelease];

	if (self.civicNumber) [address appendFormat:@"%@ ", self.civicNumber];
	if (self.streetAddress) [address appendFormat:@"%@", self.streetAddress];
	if (self.city) {
		if (address.length > 0) [address appendString:@", "];
		[address appendFormat:@"%@", self.city];
	}
	if (self.postalCode) {
		if (address.length > 0) [address appendString:@", "];
		[address appendFormat:@"%@", self.postalCode];
	}
	return address;
}

- (NSString *)fullAddress {
	NSMutableString *address = [[[NSMutableString alloc] init] autorelease];
	
	if (self.civicNumber) [address appendFormat:@"%@ ", self.civicNumber];
	if (self.streetAddress) [address appendFormat:@"%@", self.streetAddress];
	if (self.city) {
		if (address.length > 0) [address appendString:@"\n"];
		[address appendFormat:@"%@", self.city];
	}
	if (self.postalCode) {
		if (address.length > 0) [address appendString:@", "];
		[address appendFormat:@"%@", self.postalCode];
	}
	return address;
}



@end
