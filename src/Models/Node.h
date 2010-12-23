//
//  Node.h
//  Ile sans fil
//
//  Created by Oli on 09-10-04.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import <CoreData/CoreData.h>

@class Hotspot;

@interface Node :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * nodeId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * creationDate;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) Hotspot * hotspot;

+ (Node *)findOrCreateContactWithIdentifier:(NSString *)identifier;
+ (NSArray *)findAll;

@end



