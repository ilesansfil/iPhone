// 
//  Favorite.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 14/04/10.
//  Copyright 2010 ilesansfil. License Apache2.
//

#import "Favorite.h"
#import "Model.h"

@implementation Favorite 

@dynamic name;
@dynamic identifier;
@dynamic createdAt;


+ (Favorite *)findOrCreateContactWithIdentifier:(NSString *)identifier {
	return [[Model shared] findOrCreateObjectForEntityForName:@"Favorite" withIdentifier:identifier];
}


+ (NSArray *)findAll {
	return [[Model shared] fetchObjectsForEntityForName:@"Favorite" 
											  predicate:nil 
											   sortedBy:@"createdAt"
												  limit:0];
}

@end
