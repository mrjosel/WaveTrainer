//
//  Workout.swift
//  Wave Trainer
//
//  Created by Brian Josel on 9/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Workout)

//class for workout model
class Workout: NSManagedObject {
    
    //vars
    @NSManaged var dateFinished : NSDate?
    
    //user
    //TODO: MAKE USER
    
    //workout type
    @NSManaged var coreWorkoutPersisted : NSNumber?
    
    //assistence workouts
    @NSManaged var assistenceExercises : [assistenceExercises]?
    
    //workout cycle
    @NSManaged var workoutCyplePersisted : NSNumber?
    
    //
}