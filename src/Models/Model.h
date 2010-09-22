//
//  Model.h
//  Ile sans fil
//
//  Created by Fred Brunel on 02/08/09.
//  Copyright 2009 WhereCloud Inc. License Apache2.

//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


static const NSUInteger kModelLimitInfinite = INT_MAX;

@interface Model : NSObject {
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;	
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

//

+ (Model *)shared;

- (Model *)wipe;
- (Model *)save;

// Core Data Helpers

- (id)findOrCreateObjectForEntityForName:(NSString *)entityName withIdentifier:(NSString *)identifier;
- (id)findFirstObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)sortKey;
- (id)insertNewObjectForEntityForName:(NSString *)entityName;
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)key limit:(NSUInteger)limit;

- (void)deleteObject:(NSManagedObject *)object;
- (void)deleteObjects:(NSArray *)objects;

@end
