//
//  Exercise.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Exercise)

//class for exercises
class Exercise : NSManagedObject {
    
    //managed vars
    @NSManaged var sets : NSNumber
    @NSManaged fileprivate var repsPersisted : NSNumber?
    @NSManaged var name : String
    @NSManaged fileprivate var orderPersisted : NSNumber
    @NSManaged fileprivate var isCorePersisted : NSNumber
    @NSManaged var workout : Workout
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(dict: [String: String], isCore: Bool, reps: Int, order: Int, context: NSManagedObjectContext) {
        
        //create entity and call superclass initializer
        guard let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //TODO: CREATE BETTER DEFINED MODEL BASED ON RESTFUL IMPLEMENTATION
    }
    
    //intermediate vars
    //order of exercise for workout
    var order : Int {
        get {
            return Int(self.orderPersisted)
        }
        
        set {
            if !self.isCore {
                self.orderPersisted = NSNumber(value: newValue)
            }
        }
    }
    
    //boolean to denote if exercise is core or not
    var isCore : Bool {
        get {
            //return true if isCorePersisted is 1
            return self.isCorePersisted == 1
        }
        set {
            //if setting true, then set order to 0 as well
            if newValue {
                self.isCorePersisted = 1
                self.order = 0
            } else {
                //not a core exercise, don't force order
                self.isCorePersisted = 0
            }
            
        }
    }
    
    //set all intermediate vars from persisted vars during awake from fetch
    override func awakeFromFetch() {
        self.order = Int(self.orderPersisted)
        self.isCore = self.isCorePersisted == 1
    }
}
