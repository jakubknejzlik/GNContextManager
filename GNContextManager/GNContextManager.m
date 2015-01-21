 //
//  ContextManager.m
//  ProSheet
//
//  Created by Jakub Knejzlík on 13/9/11.
//  Copyright 2011 TOMATO. All rights reserved.
//

#import "GNContextManager.h"
#import <CWLSynthesizeSingleton/CWLSynthesizeSingleton.h>


@interface GNContextManager ()
@property (nonatomic,strong) NSMutableDictionary *managedObjectContexts;
@property (nonatomic,strong) NSMutableDictionary *managedObjectModels;
@property (nonatomic,strong) NSMutableDictionary *persistentStoreCoordinators;
@end


@implementation GNContextManager
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(GNContextManager, sharedInstance);


-(NSMutableDictionary *)managedObjectContexts{
    if (!_managedObjectContexts) {
        _managedObjectContexts = [NSMutableDictionary dictionary];
    }
    return _managedObjectContexts;
}
-(NSMutableDictionary *)managedObjectModels{
    if (!_managedObjectModels) {
        _managedObjectModels = [NSMutableDictionary dictionary];
    }
    return _managedObjectModels;
}
-(NSMutableDictionary *)persistentStoreCoordinators{
    if (!_persistentStoreCoordinators) {
        _persistentStoreCoordinators = [NSMutableDictionary dictionary];
    }
    return _persistentStoreCoordinators;
}

-(NSManagedObjectContext *)mainQueueManagedObjectContext{
    NSManagedObjectContext *context = [self.managedObjectContexts objectForKey:@"__default_context"];
    if (!context) {
        context = [self managedObjectContextWithSettings:[GNContextSettings mainQueueDefaultSettings]];
        [self.managedObjectContexts setObject:context forKey:@"__default_context"];
    }
    return context;
}


-(NSManagedObjectContext *)managedObjectContextWithSettings:(GNContextSettings *)settings{
    NSManagedObjectContext *context;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithSettings:settings managedObjectModel:[self managedObjectModelWithSettings:settings]];
    if (coordinator != nil)
    {
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:settings.concurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */

- (NSManagedObjectModel *)managedObjectModelWithSettings:(GNContextSettings *)settings
{
    NSString *path = settings.managedObjectModelPath;
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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithSettings:(GNContextSettings *)settings managedObjectModel:(NSManagedObjectModel *)model
{
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [self.persistentStoreCoordinators objectForKey:settings.persistentStoreUrl];
    
    if(!persistentStoreCoordinator){
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        if (![persistentStoreCoordinator addPersistentStoreWithType:settings.persistentStoreType configuration:nil URL:settings.persistentStoreUrl options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error])
        {
            [[NSFileManager defaultManager] removeItemAtURL:settings.persistentStoreUrl error:nil];
            if(self.canResetPersistentStoreOnFail){
                if (![persistentStoreCoordinator addPersistentStoreWithType:settings.persistentStoreType configuration:settings.persistentStoreConfiguration URL:settings.persistentStoreUrl options:settings.persistentStoreOptions error:&error]){
                    abort();
                    return nil;
                }
            }else{
                abort();
                return nil;
            }
        }
        [self.persistentStoreCoordinators setObject:persistentStoreCoordinator forKey:settings.persistentStoreUrl];
    }
    
    return persistentStoreCoordinator;
}




#pragma mark - OLD DEPRECATE API


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
    [self.managedObjectContexts removeAllObjects];
    [self.managedObjectModels removeAllObjects];
    [self.persistentStoreCoordinators removeAllObjects];
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
    NSManagedObjectContext *context = key?[self.managedObjectContexts objectForKey:key]:nil;
    
    if(!context){
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithStoreAtURL:persistentStoreURL withType:persistentStoreType managedObjectModel:model];
        if (coordinator != nil)
        {
            context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
            [context setPersistentStoreCoordinator:coordinator];
            if(key){
                [self.managedObjectContexts setObject:context forKey:key];
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
    NSManagedObjectModel *model = path?[self.managedObjectModels objectForKey:path]:nil;
    
    if(!model){
        
//        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"momd"];
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
        [self.managedObjectModels setObject:model forKey:path];
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

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [self.persistentStoreCoordinators objectForKey:storeURL];
    
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
        [self.persistentStoreCoordinators setObject:persistentStoreCoordinator forKey:storeURL];
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








