//
//  CoreExercise.swift
//  Wave Trainer
//
//  Created by Brian Josel on 9/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Exercise)

class CoreExercise : NSManagedObject, ExerciseProtocol {
    
    //exercise name
    @NSManaged var exerciseName : String?
    
    //image
    @NSManaged var imageName : String?
    
    //Reps
    @NSManaged var reps : NSNumber?
    
    //weight
    @NSManaged var weight : NSNumber?
    
    //core exercise
    @NSManaged var coreExerciseTypePersisted : NSNumber?
    
    //type unpersisted
    var type : CoreExerciseType? {
        didSet {
            if let type = type {
                self.coreExerciseTypePersisted = type.rawValue
            }
        }
    }
    
    //initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coreExerciseType: CoreExerciseType?, context: NSManagedObjectContext) {
        
        //core data component
        let entity = NSEntityDescription.entityForName("CoreExercise", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set vars based on type
        if let type = coreExerciseType {
            self.exerciseName = CoreExerciseType.exerciseNames[type]
            self.coreExerciseTypePersisted = type.rawValue
        }
    }
    
    //when awakened from fetch
    override func awakeFromFetch() {
        //converts persisted type (Int) to enum CoreExerciseType
        if let type = self.coreExerciseTypePersisted {
            self.type = CoreExerciseType(rawValue: Int(type))
        }
    }
    
}