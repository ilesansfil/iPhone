//
//  News.h
//  Ile sans fil
//
//  Created by thomas dobranowski on 12/05/10.
//  Copyright 2010 ilesansfil. License Apache2
//

#import <CoreData/CoreData.h>


@interface News :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * writer;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;



+ (News *)findOrCreateContactWithIdentifier:(NSString *)identifier;
+ (NSArray *)findAll;
@end



