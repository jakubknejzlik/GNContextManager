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
//CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(GNContextManager,sharedInstance);

@property (nonatomic,copy) NSString *defaultManagedObjectContextKey;
@property (nonatomic,copy) NSString *defaultManagedObjectModelPath;
@property (nonatomic,copy) NSURL *defaultPersistentStoreURL;
@property (nonatomic,copy) NSString *defaultPersistentStoreType;
@property BOOL canResetPersistentStoreOnFail;

+(instancetype)sharedInstance;

-(NSManagedObjectContext *)defaultManagedObjectContext;
-(NSManagedObjectContext *)temporaryManagedObjectContext;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key;

-(void)clearCache;

-(void)destroyDefaultManagedObjectContext;
-(void)destroyManagedObjectContextForKey:(NSString *)key;

-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath;
-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL;
-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType;

-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath;
-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL;
-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType;


-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType;

-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model persistentStoreURL:(NSURL *)persistentStoreURL;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType;

- (BOOL)saveDefaultContext;
- (BOOL)saveContextWithKey:(NSString *)key error:(NSError **)error;
- (NSString *)applicationDocumentsDirectory;



@end

@interface NSManagedObjectContext (Getters)

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

-(id)objectWithName:(NSString *)entityName hashID:(NSString *)hashID;
-(id)objectWithName:(NSString *)entityName ID:(NSString *)ID;
-(id)createOrGetObjectWithName:(NSString *)entityName ID:(NSString *)ID;

+(void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock error:(NSError **)error;
+(void)saveDataInBackgroundContext:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void(^)(NSError *error))completion;
+(void)saveDataInBackgroundContextWithCompletion:(void(^)(NSManagedObjectContext *context,void (^completion)(NSError *error)))saveBlock completion:(void(^)(NSError *error))completion;

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
+(void)deleteObjectsWithName:(NSString *)name inBackgroundWithCompletionHandler:(void(^)(NSError *error))completionHandler;

@end