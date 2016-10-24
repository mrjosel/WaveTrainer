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
        
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.dummyContext = managedObjectContext
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.dummyContext = nil
    }
    
    //tests to confirm the Wave initializer returns when no input params are given
    func waveTests() {
        
        //success cases
        //wave has a start date, incomplete, without an end date
        let potentialWave1 = Wave(startDate: Date(), endDate: nil, completed: false, context: dummyContext!)
        
        //tests 1-4
        XCTAssertNotNil(potentialWave1)                     //test that Wave is not nil
        XCTAssertNotNil(potentialWave1?.completed)          //test that persisted var is set
        XCTAssertNotNil(potentialWave1?.startDatePersisted) //test that persisted var is set
        XCTAssertNil(potentialWave1?.endDate)               //test that persisted var is nil
        XCTAssertNil(potentialWave1?.name)                  //test that persisted var is not set
        
        let timeInterval : TimeInterval = 50000
        let futureDate = Date(timeInterval: timeInterval, since: Date())
        let pastDate = Date(timeInterval: -timeInterval, since: Date())
        
        //wave has a start date, and endDate later in time, and is complete
        let potentialWave2 = Wave(startDate: Date(), endDate: futureDate, completed: true, context: dummyContext!)
        
        //tests 5-8
        XCTAssertNotNil(potentialWave2)                     //test that Wave is not nil
        XCTAssertNotNil(potentialWave2?.completed)          //test that persisted var is set
        XCTAssertNotNil(potentialWave2?.startDatePersisted) //test that persisted var is set
        XCTAssertNotNil(potentialWave2?.endDate)            //test that persisted var is set
        XCTAssertNil(potentialWave2?.name)                  //test that persisted var is not set
        
        //fail cases
        //endate is equal to today
        let startDate = Date()
        let endDate = startDate
        let potentialWave3 = Wave(startDate: startDate, endDate: endDate, completed: true, context: dummyContext!)
        
        //test 9
        XCTAssertNil(potentialWave3, "endDate can't be same as startDate")
        
        //endate is before today
        let potentialWave4 = Wave(startDate: Date(), endDate: pastDate, completed: true, context: dummyContext!)
        
        //test 10
        XCTAssertNil(potentialWave4, "endate can't be sooner than startDate")
        
        //wave is complete but no endate
        let potentialWave5 = Wave(startDate: Date(), endDate: nil, completed: true, context: dummyContext!)
        
        //test 11
        XCTAssertNil(potentialWave5, "wave must have endDate if completed == true")
        
        //wave has an endDate bus is marked incomplete
        let potentialWave6 = Wave(startDate: Date(), endDate: futureDate, completed: false, context: dummyContext!)
        
        //test 12
        XCTAssertNil(potentialWave6, "wave must be marked complete if endDate is set")

    }
        //Cycle Tests
    func cycleTests() {
    
        //tests
        let potentialCycle1 = Cycle(repsCycle: .fiveReps, completed: false, context: dummyContext!)
        XCTAssertNotNil(potentialCycle1)
        
        let potentialCycle2 = Cycle(repsCycle: .threeReps, completed: true, context: dummyContext!)
        XCTAssertNotNil(potentialCycle2)
        
        let potentialCycle3 = Cycle(repsCycle: .fiveThreeOneReps, completed: true, context: dummyContext!)
        XCTAssertNotNil(potentialCycle3)
        
        let potentialCycle4 = Cycle(repsCycle: .deload, completed: false, context: dummyContext!)
        XCTAssertNotNil(potentialCycle4)
        
    }
    
    //Workout tests
    func workoutTests() {
        
        //tests
        let potentialWorkout1 = Workout(name: "myWorkout", order: 0, context: dummyContext!)
        XCTAssertNotNil(potentialWorkout1)
    }
    
    //Exercise tests
    func exerciseTests() {
        
        //tests
        let potentialExercise1 = Exercise(coreLift: CoreLift.OHP, context: self.dummyContext!)
        XCTAssertNotNil(potentialExercise1)
        XCTAssertTrue((potentialExercise1?.isCore)!)    //should be TRUE
        potentialExercise1?.order = 1                   //should not be allowed to change
        XCTAssertFalse(potentialExercise1?.order == 1)  //should be false
        
        //create real dict
        let data : [String: AnyObject] = [
            WorkoutManagerClient.Keys.NAME : "Exercise Name" as AnyObject,
            WorkoutManagerClient.Keys.CATEGORY : "Phony" as AnyObject,
            WorkoutManagerClient.Keys.IMAGE : "no string" as AnyObject
            ]
        let realDict : [String: AnyObject] = [
            WorkoutManagerClient.Keys.DATA : data as AnyObject
        ]
        
        //test with realDict
        let potentialExercise2 = Exercise(dict: realDict, reps: nil, order: nil, context: self.dummyContext!)
        XCTAssertNotNil(potentialExercise2)
        XCTAssertFalse((potentialExercise2?.isCore)!)  //should be false
        
        //create exerciseDict from exercise, compare values
        let exerciseDict = potentialExercise2?.makeExerciseDict()
        XCTAssertNotNil(exerciseDict)
        XCTAssertTrue(exerciseDict?[WorkoutManagerClient.Keys.NAME] as! String == data[WorkoutManagerClient.Keys.NAME] as! String)
        XCTAssertTrue(exerciseDict?[WorkoutManagerClient.Keys.CATEGORY] as! String == data[WorkoutManagerClient.Keys.CATEGORY] as! String)
        XCTAssertTrue(exerciseDict?[WorkoutManagerClient.Keys.IMAGE] as! String == data[WorkoutManagerClient.Keys.IMAGE] as! String)
        XCTAssertTrue(exerciseDict?["isCorePersisted"] as? Bool == potentialExercise2?.isCore)
        XCTAssertNil(exerciseDict?["reps"])
        XCTAssertNil(exerciseDict?["sets"])
        XCTAssertNil(exerciseDict?["order"])
        
        //create phony dict
        let phonyDict : [String: AnyObject] = ["not a dict" : String() as AnyObject]
        
        //test with phony dict
        let potentialExercise3 = Exercise(dict: phonyDict, reps: nil, order: nil, context: self.dummyContext!)
        XCTAssertNil(potentialExercise3)
       
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
