//
//  Cycle.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/7/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Cycle)

//RepsCycle enum - A Cycle can either be of 5 reps, 3 reps, or 5-3-1 reps
enum RepsCycle : Int, CustomStringConvertible {
    case FiveReps = 5, ThreeReps = 3, FiveThreeOneReps = 1, Deload = 0
    
    static let RepsCycleNames = [
        FiveReps : "5 Reps Cycle",
        ThreeReps : "3 Reps Cycle",
        FiveThreeOneReps : "5-3-1 Reps Cycle",
        Deload : "Deload Cycle"
    ]
    
    //description var for CustomStringConvertible conformance
    var description: String {
        get {
            return RepsCycle.RepsCycleNames[self]!
        }
    }
}

enum RepsCycleError : ErrorType {
    case RawValIs2
    case RawValIs4
    case RawValIsGreaterThan5
}

//Cycle class - a Cycle denotes the workout and reps schedule within a Wave
class Cycle : NSManagedObject {
    
    //managed vars
    @NSManaged var repsCyclePersisted : NSNumber
    @NSManaged var completedPersisted : NSNumber
//    @NSManaged var workouts : [Workout]   //TODO: CREATE WORKOUT CLASS
    
    //initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init?(repsCycle : RepsCycle, completed: Bool, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Cycle", inManagedObjectContext: context) else {
            return nil
        }
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set intermediate vars, intermediate vars will set managed vars
        //TODO: CREATE SETTERS
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
            self.repsCyclePersisted = newValue.rawValue
        }
    }
    
}