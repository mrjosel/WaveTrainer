//
//  Exercise.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Exercise)

//enum for core exercises
enum CoreLift : Int, CustomStringConvertible, CaseCountable {
    case OHP = 0, Deadlift, BenchPress, Squat
    
    //names of lifts
    static let CoreLiftNames = [
        OHP : "Overhead Press",
        Deadlift : "Deadlift",
        BenchPress : "Bench Press",
        Squat : "Squat"
    ]
    
    //count of number of settings
    static let caseCount: Int = CoreLift.countCases()
    
    //var for CustomStringConvertible conformance
    var description: String {
        get {
            return CoreLift.CoreLiftNames[self]!
        }
    }
    
    //image
    var imagePath : String? {
        get {
            return nil  //TODO: GET IMAGE FROM URLs
        }
    }
}

//class for exercises
class Exercise : NSManagedObject {
    
    //managed vars
    @NSManaged var sets : NSNumber?
    @NSManaged private var repsPersisted : NSNumber?
    @NSManaged var name : String
    @NSManaged private var orderPersisted : NSNumber?
    @NSManaged private var isCorePersisted : NSNumber
    @NSManaged var category : String?
    @NSManaged var imagePath : String?
    @NSManaged var workout : Workout?
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    //creating any type of exercise from a dict
    init?(dict: [String: AnyObject], isCore: Bool, reps: Int?, order: Int?, context: NSManagedObjectContext) {
        
        //create entity and call superclass initializer
        guard let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //set params
        self.name = dict[WorkoutManagerClient.Keys.NAME] as! String
        self.imagePath = dict[WorkoutManagerClient.Keys.IMAGE] as? String
        self.category = dict[WorkoutManagerClient.Keys.CATEGORY] as? String
        
    }
    
    //creating a specific core lift from core lift enum
    init?(coreLift: CoreLift, context: NSManagedObjectContext) {
        //create entity and call superclass initializer
        guard let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //set params
        self.name = coreLift.description
        self.imagePath = coreLift.imagePath
        self.category = nil     //TODO: REVISE USE OF CATEGORY?
    }
    
    //intermediate vars
    //order of exercise for workout
    var order : Int? {
        get {
            guard let val = self.orderPersisted else {
                return nil
            }
            return Int(val)
        }
        
        set {
            guard let val = newValue else {
                self.orderPersisted = nil
                return
            }
            
            if !self.isCore {
                self.orderPersisted = NSNumber(value: val)
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
    
    //image from imagePath
    var image : UIImage? //TODO: GETTER AND SETTER USING IMAGE CACHING
    
    //set all intermediate vars from persisted vars during awake from fetch
    override func awakeFromFetch() {
        self.order = self.orderPersisted as Int?
        self.isCore = self.isCorePersisted == 1
    }
}
