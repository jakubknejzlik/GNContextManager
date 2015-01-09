 //
//  ContextManager.m
//  ProSheet
//
//  Created by Jakub Knejzlík on 13/9/11.
//  Copyright 2011 TOMATO. All rights reserved.
//

#import "GNContextManager.h"


@interface GNContextManager (){
    NSMutableDictionary *_managedObjectContexts;
    NSMutableDictionary *_managedObjectModels;
    NSMutableDictionary *_persistentStoreCoordinators;
}
@end


@implementation GNContextManager
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(GNContextManager, sharedInstance);

-(instancetype)initWithModelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType{
    self = [super init];
    if (self) {
        self.managedObjectModelPath = modelPath;
        self.persistentStoreURL = persistentStoreURL;
        self.persistentStoreType = persistentStoreType;
    }
    return self;
}

-(NSString *)defaultManagedObjectContextKey{
    if(!_defaultManagedObjectContextKey)return @"default";
    return _defaultManagedObjectContextKey;
}
-(NSString *)managedObjectModelPath{
    if(!_managedObjectModelPath)return [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    return _managedObjectModelPath;
}
-(NSURL *)persistentStoreURL{
    if(!_persistentStoreURL)return [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"MainDB.sqlite"]];
    return _persistentStoreURL;
}
-(NSString *)persistentStoreType{
    if(!_persistentStoreType)return NSSQLiteStoreType;
    return _persistentStoreType;
}

- (BOOL)saveDefaultContext{
    return [self saveContextWithKey:self.defaultManagedObjectContextKey error:nil];
}
- (BOOL)saveContextWithKey:(NSString *)key error:(NSError **)error
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContextForKey:key];
    if ([managedObjectContext hasChanges]){
        return [managedObjectContext save:error];
    }
    return YES;
}


-(NSManagedObjectContext *)defaultManagedObjectContext{
    return [self managedObjectContextForKey:self.defaultManagedObjectContextKey];
}
-(NSManagedObjectContext *)temporaryManagedObjectContext{
    return [self temporaryManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
}
-(NSManagedObjectContext *)temporaryManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    return [self managedObjectContextForKey:nil concurrencyType:concurrencyType];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key{
    return [self managedObjectContextForKey:key concurrencyType:NSMainQueueConcurrencyType];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    return [self managedObjectContextForKey:key modelPath:self.managedObjectModelPath persistentStoreURL:self.persistentStoreURL persistentStoreType:self.persistentStoreType concurrencyType:concurrencyType];
}


-(void)flush{
    [_managedObjectContexts removeAllObjects];
    [_managedObjectModels removeAllObjects];
    [_persistentStoreCoordinators removeAllObjects];
}


-(void)destroyDefaultManagedObjectContext{
    [self destroyManagedObjectContextForKey:self.defaultManagedObjectContextKey];
}
-(void)destroyManagedObjectContextForKey:(NSString *)key{
    [_managedObjectContexts removeObjectForKey:key];
}

-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    return [self managedObjectContextForKey:key model:[self managedObjectModelWithPath:modelPath] persistentStoreURL:persistentStoreURL persistentStoreType:persistentStoreType concurrencyType:concurrencyType];
}


-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    if(!_managedObjectContexts)_managedObjectContexts = [[NSMutableDictionary alloc] init];
    
    NSManagedObjectContext *context = key?[_managedObjectContexts objectForKey:key]:nil;
    
    if(!context){
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithStoreAtURL:persistentStoreURL withType:persistentStoreType managedObjectModel:model];
        if (coordinator != nil)
        {
            context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
            [context setPersistentStoreCoordinator:coordinator];
            if(key){
                [_managedObjectContexts setObject:context forKey:key];
            }
        }
    }
    return context;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */

- (NSManagedObjectModel *)managedObjectModelWithPath:(NSString *)path
{
    if(!_managedObjectModels)_managedObjectModels = [[NSMutableDictionary alloc] init];

    NSManagedObjectModel *model = path?[_managedObjectModels objectForKey:path]:nil;
    
    if(!model){
        
//        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"momd"];
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
        [_managedObjectModels setObject:model forKey:path];
    }
    return model;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreAtURL:(NSURL *)URL withType:(NSString *)type{
    return [self persistentStoreCoordinatorWithStoreAtURL:URL withType:type managedObjectModelPath:self.managedObjectModelPath];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreAtURL:(NSURL *)storeURL withType:(NSString *)type managedObjectModelPath:(NSString *)modelPath
{
    return [self persistentStoreCoordinatorWithStoreAtURL:storeURL withType:type managedObjectModel:[self managedObjectModelWithPath:modelPath]];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreAtURL:(NSURL *)storeURL withType:(NSString *)type managedObjectModel:(NSManagedObjectModel *)model
{
    if(!_persistentStoreCoordinators)_persistentStoreCoordinators = [[NSMutableDictionary alloc] init];

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [_persistentStoreCoordinators objectForKey:storeURL];

    if(!persistentStoreCoordinator){
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        if (![persistentStoreCoordinator addPersistentStoreWithType:type configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error])
        {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            if(self.canResetPersistentStoreOnFail){
                if (![persistentStoreCoordinator addPersistentStoreWithType:type configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error]){
                    abort();
                    return nil;
                }
            }else{
                abort();
                return nil;
            }
        }
        [_persistentStoreCoordinators setObject:persistentStoreCoordinator forKey:storeURL];
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] relativePath];
}


@end







@implementation NSManagedObjectContext (Getters)

-(NSManagedObjectContext *)childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [childContext setParentContext:self];
    return childContext;
}


-(id)createObjectWithName:(NSString *)entityName{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}
-(NSArray *)objectsWithName:(NSString *)entityName{
    return [self objectsWithName:entityName predicate:nil sortDescriptors:nil limit:0 offset:0];
}
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate{
    return [self objectsWithName:entityName predicate:predicate sortDescriptors:nil limit:0 offset:0];
}
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [self objectsWithName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0 offset:0];
}
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [self objectsWithName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:0];
}
-(NSArray *)objectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    request.entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    request.predicate=predicate;
    request.sortDescriptors=sortDescriptors;
    request.fetchLimit=limit;
    request.fetchOffset=offset;
    return [self objectsWithRequest:request];
}
-(NSArray *)objectsWithRequest:(NSFetchRequest *)request{
    NSError *error=nil;
    NSArray *array=nil;
    array=[self executeFetchRequest:request error:&error];
    NSAssert1(error == nil,@"fetch error",error);
    return array;
}


-(NSInteger)numberOfObjectsWithName:(NSString *)entityName{
    return [self numberOfObjectsWithName:entityName predicate:nil];
}
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate{
    return [self numberOfObjectsWithName:entityName predicate:predicate sortDescriptors:nil];
}
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [self numberOfObjectsWithName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0];
}
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [self numberOfObjectsWithName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:0];
}
-(NSInteger)numberOfObjectsWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    request.entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    request.predicate=predicate;
    request.sortDescriptors=sortDescriptors;
    request.fetchLimit=limit;
    request.fetchOffset=offset;
    return [self numberOfObjectsWithRequest:request];
}
-(NSInteger)numberOfObjectsWithRequest:(NSFetchRequest *)request{
    return [self countForFetchRequest:request error:nil];
}


#if TARGET_OS_IPHONE
-(NSFetchedResultsController *)fetchedResultsControllerWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [self fetchedResultsControllerWithName:entityName predicate:predicate sortDescriptors:sortDescriptors sectionNameKeyPath:nil cacheName:nil];
}
-(NSFetchedResultsController *)fetchedResultsControllerWithName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName{
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    request.entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    request.predicate=predicate;
    request.sortDescriptors=sortDescriptors;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
}
#endif


-(id)objectWithName:(NSString *)entityName ID:(id)ID attributeName:(NSString *)attributeName{
    return [[self objectsWithName:entityName predicate:[NSPredicate predicateWithFormat:@"%K = %@",attributeName,ID,nil]] lastObject];
}
-(id)createOrGetObjectWithName:(NSString *)entityName ID:(id)ID attributeName:(NSString *)attributeName{
    id obj=[self objectWithName:entityName ID:ID attributeName:attributeName];
    if(!obj){
        obj=[self createObjectWithName:entityName];
        [obj setValue:ID forKey:attributeName];
    }
    return obj;    
}



+(void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock error:(NSError *__autoreleasing *)error{
    @synchronized(self){
        NSManagedObjectContext *context=[[GNContextManager sharedInstance] temporaryManagedObjectContext];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        NSManagedObjectContext *defaultContext=[[GNContextManager sharedInstance] defaultManagedObjectContext];
        [defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [defaultContext startObservingContext:context];
        
        @synchronized(context){
            saveBlock(context);
        }
        
        if ([context hasChanges]) {
            [context save:error];
        }
        [defaultContext stopObservingContext:context];
    }
}
+(void)saveDataInBackgroundContext:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void (^)(NSError *))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        __block NSError *error;
        [NSManagedObjectContext saveDataInContext:saveBlock error:&error];
        dispatch_async(dispatch_get_main_queue(),^{
            completion(error);
        });
    });
}

-(void)startObservingContext:(NSManagedObjectContext *)context{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    [nc addObserver:self
           selector:@selector(mergeChanges:)
               name:NSManagedObjectContextDidSaveNotification
             object:context];
}
-(void)stopObservingContext:(NSManagedObjectContext *)context{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    [nc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
}


-(void)mergeChanges:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
}

-(void)deleteAllObjects{
    for (NSEntityDescription *ent in [self.persistentStoreCoordinator.managedObjectModel entities]) {
        [self deleteObjectsWithName:ent.name];
    }
}
-(void)deleteObjectsWithName:(NSString *)name{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:name];
    req.includesPropertyValues = NO;
    NSArray *objs = [self executeFetchRequest:req error:nil];
    for (NSManagedObject *obj in objs) {
        [self deleteObject:obj];
    }
}
+(void)deleteAllObjectsInBackgroundWithCompletionHandler:(void(^)(NSError *error))completionHandler{
    [self saveDataInBackgroundContext:^(NSManagedObjectContext *context) {
        [context deleteAllObjects];
    } completion:completionHandler];
}

@end
