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
    
    //category
    var category : String {
        get {
            switch self {
            case .OHP:
                return WorkoutManagerClient.CoreCategories.SHOULDERS
            case .Deadlift:
                return WorkoutManagerClient.CoreCategories.BACK
            case .BenchPress:
                return WorkoutManagerClient.CoreCategories.CHEST
            case .Squat:
                return WorkoutManagerClient.CoreCategories.LEGS
            }
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
    @NSManaged var reps : NSNumber?
    @NSManaged var name : String
    @NSManaged var order : NSNumber?
    @NSManaged private var isCorePersisted : NSNumber
    @NSManaged var category : String?
    @NSManaged var imagePath : String?
    @NSManaged var workout : Workout?
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    //creating any type of exercise from a dict
    init?(dict: [String: AnyObject], reps: Int?, order: Int?, context: NSManagedObjectContext) {
        
        //create entity and call superclass initializer
        guard let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //get data from dict
        guard let data = dict[WorkoutManagerClient.Keys.DATA] as? [String : AnyObject] else {
            return nil
        }
        
        //set params
        self.name = data[WorkoutManagerClient.Keys.NAME] as! String
        self.imagePath = data[WorkoutManagerClient.Keys.IMAGE] as? String
        self.category = data[WorkoutManagerClient.Keys.CATEGORY] as? String
        self.isCorePersisted = 0 //using a dict is NEVER for a core lift
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
        self.category = coreLift.category
        self.isCorePersisted = 1 //using core lift enum is always for a core lift
    }
    
    //intermediate vars
    
    //boolean to denote if exercise is core or not
    var isCore : Bool {
        get {
            //return true if isCorePersisted is 1
            return self.isCorePersisted == 1
        }
    }
    
    //image from imagePath
    var image : UIImage? //TODO: GETTER AND SETTER USING IMAGE CACHING
    
    //returns dict of Exercise from self, similar to a JSON
    class func makeExerciseDict(_ exercise : Exercise) -> [String : AnyObject] {
        
        //output data
        var output = [String : AnyObject]()
        
        //add all managed vars to dict EXCEPT workout
        output["name"] = exercise.name as AnyObject?
        output["isCorePersisted"] = exercise.isCorePersisted as AnyObject?
        output["sets"] = exercise.sets as AnyObject?
        output["reps"] = exercise.reps as AnyObject?
        output["order"] = exercise.order as AnyObject?
        output["category"] = exercise.category as AnyObject?
        output["imagePath"] = exercise.imagePath as AnyObject?
        
        //return output dict
        return output
    }
    
    //set all intermediate vars from persisted vars during awake from fetch
    override func awakeFromFetch() {
        
    }
}
