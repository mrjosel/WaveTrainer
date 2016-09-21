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
    @NSManaged var workout : Workout
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
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
