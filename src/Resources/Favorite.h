//
//  Favorite.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 14/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Favorite :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * identifier;

+ (Favorite *)findOrCreateContactWithIdentifier:(NSString *)identifier;
+ (NSArray *)findAll;

@end



