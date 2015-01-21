//
//  NSManagedObject+GNContextManager.h
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (GNContextManager)

-(NSManagedObjectContext *)childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

-(id)createObjectWithName:(NSString *)entityName;
-(NSArray *)objectsWithName:(NSString *)entityName;
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate;
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit;
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset;
-(NSArray *)objectsWithRequest:(NSFetchRequest *)request;

-(NSInteger)numberOfObjectsWithName:(NSString *)entityName;
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate;
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit;
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset;
-(NSInteger)numberOfObjectsWithRequest:(NSFetchRequest *)request;

#if TARGET_OS_IPHONE
-(NSFetchedResultsController *)fetchedResultsControllerWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
-(NSFetchedResultsController *)fetchedResultsControllerWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName;
#endif

-(id)objectWithName:(NSString *)entityName ID:(id)ID attributeName:(NSString *)attributeName;
-(id)createOrGetObjectWithName:(NSString *)entityName ID:(id)ID attributeName:(NSString *)attributeName;

+(BOOL)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock error:(NSError **)error;
+(void)saveDataInBackgroundContext:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void(^)(NSError *error))completion;

-(void)startObservingContext:(NSManagedObjectContext *)context;
-(void)stopObservingContext:(NSManagedObjectContext *)context;

/**
 * these methos doesn't perform save
 */
-(void)deleteAllObjects;
-(void)deleteObjectsWithName:(NSString *)name;

/**
 * these methos DOES perform save
 */
+(void)deleteAllObjectsInBackgroundWithCompletionHandler:(void(^)(NSError *error))completionHandler;

@end