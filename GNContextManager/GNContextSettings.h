//
//  GNContextSettings.h
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface GNContextSettings : NSObject
@property (nonatomic,strong) NSString *managedObjectModelPath;

@property (nonatomic,strong) NSURL *persistentStoreUrl;
@property (nonatomic,strong) NSString *persistentStoreType;
@property (nonatomic,strong) NSString *persistentStoreConfiguration;
@property (nonatomic,strong) NSDictionary *persistentStoreOptions;

@property (nonatomic) NSManagedObjectContextConcurrencyType concurrencyType;

+(instancetype)mainQueueDefaultSettings;
+(instancetype)privateQueueDefaultSettings;

@end
