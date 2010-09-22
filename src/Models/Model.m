//
//  Model.m
//  Ile sans fil
//
//  
//  Copyright 2009  License Apache2.

//

#import "Model.h"
#import "Hotspot.h"
#import "Node.h"
#import "Favorite.h"
#import "News.h"

@implementation Model

@synthesize managedObjectModel 			= _managedObjectModel;
@synthesize managedObjectContext 		= _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//

+ (Model *)shared {
	static Model *_instance = nil;
	@synchronized(self) {
		if (! _instance) {
			_instance = [[Model alloc] init];
		}
	}
	return _instance;
}

- (void)dealloc {	
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];    
	[super dealloc];
}

// Core Data Helpers

- (id)findOrCreateObjectForEntityForName:(NSString *)entityName withIdentifier:(NSString *)identifier {
	NSPredicate *predicate = identifier
		? [NSPredicate predicateWithFormat:@"identifier == %@", identifier]
		: nil;
	
	id entity = [self findFirstObjectForEntityForName:entityName 
											predicate:predicate 
											 sortedBy:nil];
		
	if (entity == nil) {
		entity = [self insertNewObjectForEntityForName:entityName];
	}
	
	if (identifier) { [entity setIdentifier:identifier]; }

	return entity;
}

- (id)findFirstObjectForEntityForName:(NSString *)entityName 
							predicate:(NSPredicate *)predicate 
							 sortedBy:(NSString *)sortKey {
	
	NSArray *results = [self fetchObjectsForEntityForName:entityName 
												predicate:predicate 
												 sortedBy:sortKey
												ascending:YES
													limit:0];
	return (results.count == 0) ? nil : [results objectAtIndex:0];
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName {
	return [NSEntityDescription insertNewObjectForEntityForName:entityName
										 inManagedObjectContext:self.managedObjectContext];
}

/*- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName 
								predicate:(NSPredicate *)predicate 
								 sortedBy:(NSString *)sortKey
									limit:(NSUInteger)limit {
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	// Set the entity name
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Set the predicate
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	// Set the sort description
	if (sortKey) {
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	
	// Set the limites
	if (limit != kModelLimitInfinite) {
		[request setFetchLimit:limit];
	}
	
	NSError *error;
	NSMutableArray *fetchResults = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
	if (fetchResults == nil) {
		// FIXME: Handle the error.
	}
	
//	NSLog(@"%d result(s) [%@]", fetchResults.count, predicate);
	
	return fetchResults;
}*/
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName 
								predicate:(NSPredicate *)predicate 
								 sortedBy:(NSString *)sortKey
								ascending:(BOOL)ascending
									limit:(NSUInteger)limit {
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	// Set the entity name
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Set the predicate
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	// Set the sort description
	if (sortKey) {
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	
	// Set the limites
	if (limit != kModelLimitInfinite) {
		[request setFetchLimit:limit];
	}
	
	NSError *error;
	NSMutableArray *fetchResults = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
	if (fetchResults == nil) {
		// FIXME: Handle the error.
	}
	
	//	NSLog(@"%d result(s) [%@]", fetchResults.count, predicate);
	
	return fetchResults;
}
- (void)deleteObject:(NSManagedObject *)object {
	if (_managedObjectContext != nil) { [_managedObjectContext deleteObject:object]; }
}

- (void)deleteObjects:(NSArray *)objects {
	for (id object in objects) { [self deleteObject:object]; }
}

// Saves changes in the application's managed object context

- (Model *)save {
    NSError *error;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
			// FIXME: Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);
        } 
    }
	return self;
}

// Wipe all the data

- (Model *)wipe {
	[self deleteObjects:[Hotspot findAll]];
	[self deleteObjects:[Node findAll]];
	[self deleteObjects:[Favorite findAll]];
	[self deleteObjects:[News findAll]];
	return self;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the 
// persistent store coordinator for the application.

- (NSManagedObjectContext *)managedObjectContext {	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the 
// models found in the application bundle.

- (NSManagedObjectModel *)managedObjectModel {	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the 
// application's store added to it.

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath:
					   [self.applicationDocumentsDirectory 
						stringByAppendingPathComponent:@"isf.sqlite"]];
	
	NSDictionary *options = 
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
			[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												   configuration:nil 
															 URL:storeUrl 
														 options:options 
														   error:&error]) {
		// FIXME: Handle error
    }   
	
    return _persistentStoreCoordinator;
}

// Returns the path to the application's documents directory.

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
