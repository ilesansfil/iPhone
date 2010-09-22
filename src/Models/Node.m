// 
//  Node.m
//  Ile sans fil
//
//  Created by Oli on 09-10-04.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import "Node.h"
#import "Hotspot.h"
#import "Model.h"

@implementation Node 

@dynamic status;
@dynamic nodeId;
@dynamic longitude;
@dynamic creationDate;
@dynamic createdAt;
@dynamic latitude;
@dynamic updatedAt;
@dynamic identifier;
@dynamic hotspot;


+ (Node *)findOrCreateContactWithIdentifier:(NSString *)identifier {
	return [[Model shared] findOrCreateObjectForEntityForName:@"Node" withIdentifier:identifier];
}

+ (NSArray *)findAll {
	return [[Model shared] fetchObjectsForEntityForName:@"Node" 
															predicate:nil 
															 sortedBy:@"createdAt"
																ascending:YES
																 limit:0];
}


@end
