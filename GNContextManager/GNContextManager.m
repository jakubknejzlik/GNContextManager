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

-(NSString *)defaultManagedObjectContextKey{
    if(!_defaultManagedObjectContextKey)return @"default";
    return _defaultManagedObjectContextKey;
}
-(NSString *)defaultManagedObjectModelPath{
    if(!_defaultManagedObjectModelPath)return [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    return _defaultManagedObjectModelPath;
}
-(NSURL *)defaultPersistentStoreURL{
    if(!_defaultPersistentStoreURL)return [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"MainDB.sqlite"]];
    return _defaultPersistentStoreURL;
}
-(NSString *)defaultPersistentStoreType{
    if(!_defaultPersistentStoreType)return NSSQLiteStoreType;
    return _defaultPersistentStoreType;
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
    return [self managedObjectContextForKey:nil];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key
{
    return [self managedObjectContextForKey:key modelPath:self.defaultManagedObjectModelPath];
}


-(void)clearCache{
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


-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath{
    return [self defaultManagedObjectContextWithModelAtPath:modelPath persistentStoreURL:self.defaultPersistentStoreURL];
}
-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL{
    return [self defaultManagedObjectContextWithModelAtPath:modelPath persistentStoreURL:persistentStoreURL persistentStoreType:self.defaultPersistentStoreType];
}
-(NSManagedObjectContext *)defaultManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType{
    return [self managedObjectContextForKey:self.defaultManagedObjectContextKey modelPath:modelPath persistentStoreURL:persistentStoreURL persistentStoreType:persistentStoreType];
}

-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath{
    return [self temporaryManagedObjectContextWithModelAtPath:modelPath persistentStoreURL:self.defaultPersistentStoreURL];
}
-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL{
    return [self temporaryManagedObjectContextWithModelAtPath:modelPath persistentStoreURL:persistentStoreURL persistentStoreType:self.defaultPersistentStoreType];
}
-(NSManagedObjectContext *)temporaryManagedObjectContextWithModelAtPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType{
    return [self managedObjectContextForKey:nil modelPath:modelPath persistentStoreURL:persistentStoreURL persistentStoreType:persistentStoreType];
}



-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath{
    return [self managedObjectContextForKey:key modelPath:modelPath persistentStoreURL:self.defaultPersistentStoreURL];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL{
    return [self managedObjectContextForKey:key modelPath:modelPath persistentStoreURL:persistentStoreURL persistentStoreType:self.defaultPersistentStoreType];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType{
    return [self managedObjectContextForKey:key model:[self managedObjectModelWithPath:modelPath] persistentStoreURL:persistentStoreURL persistentStoreType:persistentStoreType];
}

-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model{
    return [self managedObjectContextForKey:key model:model persistentStoreURL:self.defaultPersistentStoreURL];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model persistentStoreURL:(NSURL *)persistentStoreURL{
    return [self managedObjectContextForKey:key model:model persistentStoreURL:persistentStoreURL persistentStoreType:self.defaultPersistentStoreType];
}
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key model:(NSManagedObjectModel *)model persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType{
    if(!_managedObjectContexts)_managedObjectContexts = [[NSMutableDictionary alloc] init];
    
    NSManagedObjectContext *context = key?[_managedObjectContexts objectForKey:key]:nil;
    
    if(!context){
        NSLog(@"creating context %@",key);
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithStoreAtURL:persistentStoreURL withType:persistentStoreType managedObjectModel:model];
        if (coordinator != nil)
        {
            context = [[NSManagedObjectContext alloc] init];
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
//- (NSManagedObjectModel *)defaultManagedObjectModel
//{
//    return [self managedObjectModelWithPath:self.defaultManagedObjectModelPath];
//}
- (NSManagedObjectModel *)managedObjectModelWithPath:(NSString *)path
{
    if(!_managedObjectContexts)_managedObjectContexts = [[NSMutableDictionary alloc] init];

    NSManagedObjectModel *model = path?[_managedObjectContexts objectForKey:path]:nil;
    
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
//- (NSPersistentStoreCoordinator *)defaultPersistentStoreCoordinator{
//    return [self persistentStoreCoordinatorWithFileAtURL:self.defaultPersistentStoreURL withType:self.defaultPersistentStoreType];
//}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreAtURL:(NSURL *)URL withType:(NSString *)type{
    return [self persistentStoreCoordinatorWithStoreAtURL:URL withType:type managedObjectModelPath:self.defaultManagedObjectModelPath];
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


-(id)objectWithName:(NSString *)entityName hashID:(NSString *)hashID{
    return [[self objectsWithName:entityName predicate:[NSPredicate predicateWithFormat:@"hashID = %@",hashID,nil]] lastObject];
}
-(id)objectWithName:(NSString *)entityName ID:(NSString *)ID{
    return [[self objectsWithName:entityName predicate:[NSPredicate predicateWithFormat:@"id = %@",ID,nil]] lastObject];
}
-(id)createOrGetObjectWithName:(NSString *)entityName ID:(NSString *)ID{
    id obj=[self objectWithName:entityName ID:ID];
    if(!obj){
        obj=[self createObjectWithName:entityName];
        if([obj respondsToSelector:@selector(setId:)]){
            [obj performSelector:@selector(setId:) withObject:ID];
        }
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
+(void)saveDataInBackgroundContextWithCompletion:(void(^)(NSManagedObjectContext *context,void (^completion)(NSError *error)))saveBlock completion:(void (^)(NSError *))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        @synchronized(self){
//            NSThread *thread = [NSThread currentThread];
            NSManagedObjectContext *context=[[GNContextManager sharedInstance] temporaryManagedObjectContext];
            [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            NSManagedObjectContext *defaultContext=[[GNContextManager sharedInstance] defaultManagedObjectContext];
            [defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
            [defaultContext startObservingContext:context];
            
            __block BOOL completed = NO;
            
            void (^_completion)(NSError *error) = ^(NSError *error){
                __weak NSError *weakError = error;
//                [context performSelector:@selector(nsk_performBlock:) onThread:thread withObject:[^(){
                    //                __block NSError *error;
                    NSError *err;
                    if (!weakError && [context hasChanges]) {
                        [context save:&err];
                        NSLog(@"context saved with error %@",err);
                    }
                    [defaultContext stopObservingContext:context];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completed = YES;
                        completion(weakError?weakError:err);
                    });
//                } copy] waitUntilDone:NO];
            };
            
            @synchronized(context){
                saveBlock(context,_completion);
            }
//            
//            NSRunLoop *loop = [NSRunLoop currentRunLoop];
//            while (!completed) {
//                [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//            }
        }
    });
}

//-(void)nsk_performBlock:(void(^)(void))block{
//    block();
//}

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
+(void)deleteObjectsWithName:(NSString *)name inBackgroundWithCompletionHandler:(void(^)(NSError *error))completionHandler{
    [self saveDataInBackgroundContext:^(NSManagedObjectContext *context) {
        [context deleteObjectsWithName:name];
    } completion:completionHandler];
}

@end


//dispatch_queue_t background_save_queue(void);
//void cleanup_save_queue(void);
//
//static dispatch_queue_t coredata_background_save_queue;
//
//dispatch_queue_t background_save_queue()
//{
//    if (coredata_background_save_queue == NULL)
//    {
//        coredata_background_save_queue = dispatch_queue_create("com.thefuntasty.backgroundsaves", 0);
//    }
//    return coredata_background_save_queue;
//}
//
//void cleanup_save_queue()
//{
//	if (coredata_background_save_queue != NULL)
//	{
//		dispatch_release(coredata_background_save_queue);
//        coredata_background_save_queue = NULL;
//	}
//}
