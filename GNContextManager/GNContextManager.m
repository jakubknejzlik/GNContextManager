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
//            [persistentStoreCoordinator performBlockAndWait:^{
//                [NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:settings.persistentStoreUrl options:settings.persistentStoreOptions error:nil];
//            }];
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




@end








