//
//  Company.h
//  GNContextManager
//
//  Created by Jakub Knejzlik on 21/01/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department;

@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *departments;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addDepartmentsObject:(Department *)value;
- (void)removeDepartmentsObject:(Department *)value;
- (void)addDepartments:(NSSet *)values;
- (void)removeDepartments:(NSSet *)values;

@end
