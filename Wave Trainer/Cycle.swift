//
//  Cycle.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/7/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

//RepsCycle enum - A Cycle can either be of 5 reps, 3 reps, or 5-3-1 reps
enum RepsCycle : Int, CustomStringConvertible {
    case fiveReps = 5, threeReps = 3, fiveThreeOneReps = 1, deload = 0
    
    static let RepsCycleNames = [
        fiveReps : "5 Reps Cycle",
        threeReps : "3 Reps Cycle",
        fiveThreeOneReps : "5-3-1 Reps Cycle",
        deload : "Deload Cycle"
    ]
    
    //description var for CustomStringConvertible conformance
    var description: String {
        get {
            return RepsCycle.RepsCycleNames[self]!
        }
    }
}

enum RepsCycleError : Error {
    case rawValIs2
    case rawValIs4
    case rawValIsGreaterThan5
}

@objc(Cycle)

//Cycle class - a Cycle denotes the workout and reps schedule within a Wave
class Cycle : NSManagedObject {
    
    //managed vars
    @NSManaged var repsCyclePersisted : NSNumber
    @NSManaged var completedPersisted : NSNumber
    @NSManaged var wave : Wave
    @NSManaged var workouts : [Workout]
    //TODO: MAKE START AND END DATES
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    //attempt creation of managed object
    init?(repsCycle : RepsCycle, completed: Bool, context: NSManagedObjectContext) {
        //
        guard let entity = NSEntityDescription.entity(forEntityName: "Cycle", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //set intermediate vars, intermediate vars will set managed vars
        self.repsCycle = repsCycle
        self.completed = completed
    }
    
    //intermediate vars
    //completed to manage if cycle is complete
    var completed : Bool {
        get {
            //return true if completedPersisted set to 1
            return self.completedPersisted == 1
        }
        set {
            //persist the value
            self.completedPersisted = newValue ? 1 : 0
        }
    }
    
    //manages which reps Cycle current cycle actually is
    var repsCycle : RepsCycle  {
        get {
            //return a repsCycle based on the persisted value
            return RepsCycle(rawValue: Int(self.repsCyclePersisted))!
        }
        set {
            //persist the value
            self.repsCyclePersisted = NSNumber(value : newValue.rawValue)
        }
    }
    
}
