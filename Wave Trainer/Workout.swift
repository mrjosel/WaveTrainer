//
//  Workout.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/15/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

//workout class - each workout has Exercises, and belongs to a Cycle
class Workout: NSManagedObject {
    
    //managed vars
    @NSManaged private var namePersisted: String?
    @NSManaged var exercises: [Exercise]
    @NSManaged var completedPersisted : NSNumber
    @NSManaged private var dateCompleted : NSDate
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    //intermediate vars
    //completed variable
    var completed : Bool {
        get {
            return self.completedPersisted == 1
        }
        set {
            self.completedPersisted = newValue ? 1 : 0
        }
    }
    
    //name, based on core exercises being present
    var name : String? {
        get {
            return self.namePersisted
        }
        //TODO:  CALCULATE NAME BASED ON CORE EXERCISES
    }
}
