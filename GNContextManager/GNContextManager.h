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

typedef NS_ENUM(NSUInteger, GNContextManagerEnvironment) {
    GNContextManagerEnvironmentDefault,
    GNContextManagerEnvironmentUnitTests //all persistent stores are InMemory
};

@interface GNContextManager : NSObject
@property BOOL canResetPersistentStoreOnFail;
@property (nonatomic) GNContextManagerEnvironment environment;

+(instancetype)sharedInstance;


/**
 * context returned from this method is automaticaly strongly referenced so won't get dealloced
 */
-(NSManagedObjectContext *)mainQueueManagedObjectContext;


/**
 * make sure you hold reference to context returned from this method, not strongly referenced
 */
-(NSManagedObjectContext *)managedObjectContextWithSettings:(GNContextSettings *)settings;


@end