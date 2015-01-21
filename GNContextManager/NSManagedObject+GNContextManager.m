//
//  NSManagedObject+GNContextManager.m
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "NSManagedObject+GNContextManager.h"

#import "GNContextManager.h"

@implementation NSManagedObjectContext (GNContextManager)

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



+(BOOL)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock error:(NSError *__autoreleasing *)error{
    BOOL success = YES;
    @synchronized(self){
        NSManagedObjectContext *context=[[GNContextManager sharedInstance] managedObjectContextWithSettings:[GNContextSettings privateQueueDefaultSettings]];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        NSManagedObjectContext *defaultContext=[[GNContextManager sharedInstance] managedObjectContextWithSettings:[GNContextSettings mainQueueDefaultSettings]];
        [defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [defaultContext startObservingContext:context];
        
        @synchronized(context){
            saveBlock(context);
        }
        
        if ([context hasChanges]) {
            success = [context save:error];
        }
        [defaultContext stopObservingContext:context];
    }
    return success;
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
