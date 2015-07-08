//
//  NSManagedObject+GNContextManager.m
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "NSManagedObject+GNContextManager.h"

#import "GNContextManager.h"


@implementation NSManagedObject (GNContextManager)

+ (NSManagedObjectContext *)mainContext {
    return [[GNContextManager sharedInstance] mainQueueManagedObjectContext];
}

+ (NSString *)_className {
    return NSStringFromClass([self class]);
}

+ (NSArray *)objectsInMainContext{
    return [self objectsInContext:[self mainContext]];
}
+ (NSArray *)objectsInMainContextWithPredicate:(NSPredicate *)predicate{
    return [self objectsInContext:[self mainContext] withPredicate:predicate];
}
+ (NSArray *)objectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [self objectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors];
}
+ (NSArray *)objectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [self objectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors limit:limit];
}
+ (NSArray *)objectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    return [self objectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
}

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context{
    return [context objectsWithName:[self _className]];
}
+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate{
    return [context objectsWithName:[self _className] predicate:predicate];
}
+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [context objectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors];
}
+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [context objectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors limit:limit];
}
+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    return [context objectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
}



+ (NSInteger)numberOfObjectsInMainContext{
    return [self numberOfObjectsInContext:[self mainContext]];
}
+ (NSInteger)numberOfObjectsInMainContextWithPredicate:(NSPredicate *)predicate{
    return [self numberOfObjectsInContext:[self mainContext] withPredicate:predicate];
}
+ (NSInteger)numberOfObjectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [self numberOfObjectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors];
}
+ (NSInteger)numberOfObjectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [self numberOfObjectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors limit:limit];
}
+ (NSInteger)numberOfObjectsInMainContextWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    return [self numberOfObjectsInContext:[self mainContext] withPredicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
}

+ (NSInteger)numberOfObjectsInContext:(NSManagedObjectContext *)context{
    return [context numberOfObjectsWithName:[self _className]];
}
+ (NSInteger)numberOfObjectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate{
    return [context numberOfObjectsWithName:[self _className] predicate:predicate];
}
+ (NSInteger)numberOfObjectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors{
    return [context numberOfObjectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors];
}
+ (NSInteger)numberOfObjectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit{
    return [context numberOfObjectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors limit:limit];
}
+ (NSInteger)numberOfObjectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset{
    return [context numberOfObjectsWithName:[self _className] predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
}


+ (instancetype)createInMainContext{
    return [self createInContext:[self mainContext]];
}
+ (instancetype)createInContext:(NSManagedObjectContext *)context{
    return [context createObjectWithName:[self _className]];
}

+ (instancetype)createOrGetInMainContextWithID:(id)ID attributeName:(NSString *)attributeName{
    return [self createInContext:[self mainContext] withID:ID attributeName:attributeName];
}
+ (instancetype)createInContext:(NSManagedObjectContext *)context withID:(id)ID attributeName:(NSString *)attributeName{
    return [context createOrGetObjectWithName:[self _className] ID:ID attributeName:attributeName];
}


+ (instancetype)objectInMainContextWithID:(id)ID attributeName:(NSString *)attributeName{
    return [self objectInContext:[self mainContext] withID:ID attributeName:attributeName];
}
+ (instancetype)objectInContext:(NSManagedObjectContext *)context withID:(id)ID attributeName:(NSString *)attributeName{
    return [context objectWithName:[self _className] ID:ID attributeName:attributeName];
}

@end




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
    [self performBlockAndWait:^{
        [self mergeChangesFromContextDidSaveNotification:notification];
    }];
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
