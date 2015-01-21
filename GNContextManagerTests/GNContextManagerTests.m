//
//  GNContextManagerTests.m
//  GNContextManagerTests
//
//  Created by Jakub Knejzlik on 02/09/14.
//  Copyright (c) 2014 Jakub Knejzlik. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GNContextManager.h"
#import "model.h"

@interface GNContextManagerTests : XCTestCase
@property (nonatomic,strong) NSManagedObjectContext *privateQueueContext;
@property (nonatomic,strong) NSManagedObjectContext *mainQueueContext;
@end

@implementation GNContextManagerTests

- (void)setUp
{
    [super setUp];
    GNContextSettings *mainQueueSettings = [GNContextSettings mainQueueDefaultSettings];
    mainQueueSettings.managedObjectModelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Model" ofType:@"momd"];
    GNContextSettings *privateQueueSettings = [GNContextSettings privateQueueDefaultSettings];
    privateQueueSettings.managedObjectModelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Model" ofType:@"momd"];
    self.mainQueueContext = [[GNContextManager sharedInstance] managedObjectContextWithSettings:mainQueueSettings];
    self.privateQueueContext = [[GNContextManager sharedInstance] managedObjectContextWithSettings:privateQueueSettings];

}

- (void)tearDown
{
    [self.mainQueueContext deleteAllObjects];
    [self.mainQueueContext save:nil];
    [super tearDown];
}

- (void)testExample
{
   
    __block Person *p;
    [self.privateQueueContext performBlockAndWait:^{
        p = [self.privateQueueContext createObjectWithName:@"Person"];
        p.firstname = @"test firstname";
        p.surname = @"test surname";
        [self.privateQueueContext save:nil];
    }];
    
    [self.mainQueueContext reset];
    Person *pm = (Person *)[self.mainQueueContext objectWithID:p.objectID];
    XCTAssertEqual(pm.firstname, p.firstname);
    XCTAssertEqual(pm.surname, p.surname);
    
    [self.privateQueueContext performBlockAndWait:^{
        Company *c = [self.privateQueueContext createObjectWithName:@"Company"];
        c.name = @"Test company";
        [self.privateQueueContext save:nil];
    }];
    
    Company *c = (Company *)[[self.mainQueueContext objectsWithName:@"Company"] firstObject];
    NSLog(@"%@",c.name);
    XCTAssert([c.name isEqual:@"Test company"]);
    
    XCTAssert(self.mainQueueContext.concurrencyType == NSMainQueueConcurrencyType);
    XCTAssert(self.privateQueueContext.concurrencyType == NSPrivateQueueConcurrencyType);
    XCTAssertNotEqual(self.mainQueueContext, self.privateQueueContext);
}

@end
