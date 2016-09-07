//
//  Wave_TrainerTests.swift
//  Wave TrainerTests
//
//  Created by Brian Josel on 9/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import XCTest
import CoreData

class Wave_TrainerTests: XCTestCase {
    
    //MARK: Wave Trainer Tests
    
    //dummyContext
    var dummyContext : NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.dummyContext = managedObjectContext
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.dummyContext = nil
    }
    
    //tests to confirm the Wave initializer returns when no input params are given
    func testWaveInitializer() {
        
        //success cases
        //wave has a start date, incomplete, without an end date
        let potentialWave1 = Wave(startDate: NSDate(), endDate: nil, completed: false, context: dummyContext!)
        
        //tests 1-4
        XCTAssertNotNil(potentialWave1)                     //test that Wave is not nil
        XCTAssertNotNil(potentialWave1?.completedPersisted) //test that persisted var is set
        XCTAssertNotNil(potentialWave1?.startDatePersisted) //test that persisted var is set
        XCTAssertNil(potentialWave1?.endDatePersisted)      //test that persisted var is nil
        
        let timeInterval : NSTimeInterval = 50000
        let futureDate = NSDate(timeInterval: timeInterval, sinceDate: NSDate())
        let pastDate = NSDate(timeInterval: -timeInterval, sinceDate: NSDate())
        
        //wave has a start date, and endDate later in time, and is complete
        let potentialWave2 = Wave(startDate: NSDate(), endDate: futureDate, completed: true, context: dummyContext!)
        
        //tests 5-8
        XCTAssertNotNil(potentialWave2)                     //test that Wave is not nil
        XCTAssertNotNil(potentialWave2?.completedPersisted) //test that persisted var is set
        XCTAssertNotNil(potentialWave2?.startDatePersisted) //test that persisted var is set
        XCTAssertNotNil(potentialWave2?.endDatePersisted)   //test that persisted var is set
        
        //fail cases
        //endate is equal to today
        let startDate = NSDate()
        let endDate = startDate
        let potentialWave3 = Wave(startDate: startDate, endDate: endDate, completed: true, context: dummyContext!)
        
        //test 9
        XCTAssertNil(potentialWave3, "endDate can't be same as startDate")
        
        //endate is before today
        let potentialWave4 = Wave(startDate: NSDate(), endDate: pastDate, completed: true, context: dummyContext!)
        
        //test 10
        XCTAssertNil(potentialWave4, "endate can't be sooner than startDate")
        
        //wave is complete but no endate
        let potentialWave5 = Wave(startDate: NSDate(), endDate: nil, completed: true, context: dummyContext!)
        
        //test 11
        XCTAssertNil(potentialWave5, "wave must have endDate if completed == true")
        
        //wave has an endDate bus is marked incomplete
        let potentialWave6 = Wave(startDate: NSDate(), endDate: futureDate, completed: false, context: dummyContext!)
        
        //test 12
        XCTAssertNil(potentialWave6, "wave must be marked complete if endDate is set")
        
        
    }
    //
    //    func testExample() {
    //        // This is an example of a functional test case.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    }
    //
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    //    
}
