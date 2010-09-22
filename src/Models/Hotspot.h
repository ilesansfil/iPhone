//
//  Hotspot.h
//  Ile sans fil
//
//  Created by Oli on 09-10-04.
//  Copyright 2009 Kolt Production. License Apache2.
//

#import <CoreData/CoreData.h>

typedef enum {
	kHotspotStatusUnknow = 0,
	kHotspotStatusUp,
	kHotspotStatusDown
} HotspotStatus;

@interface Hotspot :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * civicNumber;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * contactPhoneNumber;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * massTransitInfo;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * hotspotId;
@property (nonatomic, retain) NSDate * openingDate;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSString * websiteUrl;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * contactEmail;
@property (nonatomic, retain) NSSet* nodes;

+ (Hotspot *)findOrCreateContactWithIdentifier:(NSString *)identifier;
+ (NSArray *)findAll;

- (HotspotStatus)status;
- (NSString *)fullAddressOneLine;
- (NSString *)fullAddress;

@end


@interface Hotspot (CoreDataGeneratedAccessors)
- (void)addNodesObject:(NSManagedObject *)value;
- (void)removeNodesObject:(NSManagedObject *)value;
- (void)addNodes:(NSSet *)value;
- (void)removeNodes:(NSSet *)value;

@end

