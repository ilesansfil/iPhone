// 
//  News.m
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/05/10.
//  Copyright 2010 ilesansfil. License Apache2
//

#import "News.h"
#import "Model.h"

@implementation News 

@dynamic summary;
@dynamic writer;
@dynamic title;
@dynamic link;
@dynamic identifier;
@dynamic text;
@dynamic createdAt;



+ (News *)findOrCreateContactWithIdentifier:(NSString *)identifier {
	return [[Model shared] findOrCreateObjectForEntityForName:@"News" withIdentifier:identifier];
}


+ (NSArray *)findAll {
	return [[Model shared] fetchObjectsForEntityForName:@"News" 
											  predicate:nil 
											   sortedBy:@"createdAt"
												ascending:YES
												  limit:0];
}

@end
