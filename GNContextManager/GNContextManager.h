//
//  ContextManager.h
//  ProSheet
//
//  Created by Jakub Knejzlík on 13/9/11.
//  Copyright 2011 TOMATO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CWLSynthesizeSingleton/CWLSynthesizeSingleton.h>

@interface GNContextManager : NSObject
CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(GNContextManager,sharedInstance);

@property (nonatomic,copy) NSString *defaultManagedObjectContextKey;
@property (nonatomic,copy) NSString *managedObjectModelPath;
@property (nonatomic,copy) NSURL *persistentStoreURL;
@property (nonatomic,copy) NSString *persistentStoreType;
@property BOOL canResetPersistentStoreOnFail;

-(instancetype)initWithModelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType;

-(NSManagedObjectContext *)defaultManagedObjectContext;

-(NSManagedObjectContext *)temporaryManagedObjectContext;
-(NSManagedObjectContext *)temporaryManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

-(void)flush;

-(void)destroyDefaultManagedObjectContext;
-(void)destroyManagedObjectContextForKey:(NSString *)key;

@end

@interface NSManagedObjectContext (Getters)

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

+(void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock error:(NSError **)error;
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