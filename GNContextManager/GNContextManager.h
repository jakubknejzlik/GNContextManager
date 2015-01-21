//
//  ContextManager.h
//  ProSheet
//
//  Created by Jakub Knejzlík on 13/9/11.
//  Copyright 2011 TOMATO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "NSManagedObject+GNContextManager.h"
#import "GNContextSettings.h"

@interface GNContextManager : NSObject
@property BOOL canResetPersistentStoreOnFail;

+(instancetype)sharedInstance;


-(NSManagedObjectContext *)mainQueueManagedObjectContext;

-(NSManagedObjectContext *)managedObjectContextWithSettings:(GNContextSettings *)settings;


#pragma DEPRECATE methods from old API
@property (nonatomic,copy) NSString *defaultManagedObjectContextKey DEPRECATED_ATTRIBUTE;
@property (nonatomic,copy) NSString *managedObjectModelPath DEPRECATED_ATTRIBUTE;
@property (nonatomic,copy) NSURL *persistentStoreURL DEPRECATED_ATTRIBUTE;
@property (nonatomic,copy) NSString *persistentStoreType DEPRECATED_ATTRIBUTE;

-(instancetype)initWithModelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType DEPRECATED_ATTRIBUTE;

-(NSManagedObjectContext *)defaultManagedObjectContext DEPRECATED_ATTRIBUTE;

-(NSManagedObjectContext *)temporaryManagedObjectContext DEPRECATED_ATTRIBUTE;
-(NSManagedObjectContext *)temporaryManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType DEPRECATED_ATTRIBUTE;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key DEPRECATED_ATTRIBUTE;
-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType DEPRECATED_ATTRIBUTE;

-(NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key modelPath:(NSString *)modelPath persistentStoreURL:(NSURL *)persistentStoreURL persistentStoreType:(NSString *)persistentStoreType concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyTypeDEPRECATED_ATTRIBUTE;

-(void)flush DEPRECATED_ATTRIBUTE;

-(void)destroyDefaultManagedObjectContext DEPRECATED_ATTRIBUTE;
-(void)destroyManagedObjectContextForKey:(NSString *)key DEPRECATED_ATTRIBUTE;

@end