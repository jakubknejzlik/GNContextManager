//
//  GNContextSettings.m
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "GNContextSettings.h"

#define DEFAULT_MODEL_NAME @"Model.momd"
#define DEFAULT_SQLITE_STORE_NAME @"MainDB.sqlite"

@implementation GNContextSettings

+(instancetype)defaultSettings{
    return [[GNContextSettings alloc] init];
}
+(instancetype)mainQueueDefaultSettings{
    GNContextSettings *settings = [self defaultSettings];
    settings.concurrencyType = NSMainQueueConcurrencyType;
    return settings;
}
+(instancetype)privateQueueDefaultSettings{
    GNContextSettings *settings = [self defaultSettings];
    settings.concurrencyType = NSPrivateQueueConcurrencyType;
    return settings;
}


-(NSString *)managedObjectModelPath{
    if (!_managedObjectModelPath) {
        _managedObjectModelPath = [[NSBundle mainBundle] pathForResource:[DEFAULT_MODEL_NAME stringByDeletingPathExtension] ofType:[DEFAULT_MODEL_NAME pathExtension]];
    }
    return _managedObjectModelPath;
}


-(NSURL *)persistentStoreUrl{
    if (!_persistentStoreUrl) {
        _persistentStoreUrl = [NSURL fileURLWithPath:[[self documentsDirectoryPath] stringByAppendingPathComponent:DEFAULT_SQLITE_STORE_NAME]];
    }
    return _persistentStoreUrl;
}
-(NSString *)persistentStoreConfiguration{
    return _persistentStoreConfiguration;
}
-(NSString *)persistentStoreType{
    if (!_persistentStoreType) {
        _persistentStoreType = NSSQLiteStoreType;
    }
    return _persistentStoreType;
}
-(NSDictionary *)persistentStoreOptions{
    if (!_persistentStoreOptions) {
        _persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES};
    }
    return _persistentStoreOptions;
}


- (NSString *)documentsDirectoryPath
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] relativePath];
}

@end
