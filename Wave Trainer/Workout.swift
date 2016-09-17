//
//  Workout.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/15/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Workout)

//workout class - each workout has Exercises, and belongs to a Cycle
class Workout: NSManagedObject {
    
    //managed vars
    @NSManaged private var namePersisted: String
    @NSManaged var completedPersisted : NSNumber
    @NSManaged private var dateCompleted : NSDate?
    @NSManaged var order : NSNumber
    @NSManaged var cycle : Cycle
    //@NSManaged var exercises: [Exercise]
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(name: String, order: Int, context : NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Workout", in: context) else {
            //failed to create entity, return nil
            return nil
        }
        
        //call super init
        super.init(entity: entity, insertInto: context)
        
        //set vars
        self.name = name
        self.order = NSNumber(value: order)
        self.completed = false  //new workouts are always incomplete
    }
    
    //intermediate vars
    //completed variable
    var completed : Bool {
        get {
            //return true if completedPersisted = 1
            return self.completedPersisted == 1
        }
        set {
            //if true, set completedPersisted to 1 and set the date completed to now
            if newValue {
                self.completedPersisted = 1
                self.dateCompleted = NSDate()
            } else {
                self.completedPersisted = 0
                self.dateCompleted = nil
            }
        }
    }
    
    //name, based on core exercises being present
    var name : String {
        get {
            return self.namePersisted
        }
        //TODO:  CALCULATE NAME BASED ON CORE EXERCISES
        set {
            self.namePersisted = newValue
        }
    }
}
