//
//  Department.h
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject *company;
@property (nonatomic, retain) NSSet *persons;
@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addPersonsObject:(NSManagedObject *)value;
- (void)removePersonsObject:(NSManagedObject *)value;
- (void)addPersons:(NSSet *)values;
- (void)removePersons:(NSSet *)values;

@end
