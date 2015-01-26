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


@end