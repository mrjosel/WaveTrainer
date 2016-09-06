//
//  WorkoutEnumsAndProtocols.swift
//  Wave Trainer
//
//  Created by Brian Josel on 9/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation

//protocol for exercises
protocol ExerciseProtocol : NSObjectProtocol {
    
    //exercise name
    var exerciseName : String? {get}
    
    //image
    var imageName : String? {get}
    
    //Reps
    var reps : NSNumber? {get set}
    
    //weight
    var weight : NSNumber? {get set}
    
}

//enum for workout type
enum CoreExerciseType : Int, CustomStringConvertible {
    
    //cases
    case OHP = 0, Deadlift, BenchPress, Squat
    
    //names for printing
    static let exerciseNames = [
        OHP : "Overhead Press",
        Deadlift : "Deadlift",
        BenchPress : "Bench Press",
        Squat: "Squat"
    ]
    
    //description var allows for CustomStringConvertible conformance
    var description: String {
        get {
            guard let name = CoreExerciseType.exerciseNames[self] else {
                return "Core Exercise"
            }
            return name
        }
    }
}

//enum for workout cycle
enum WorkoutCycle : Int, CustomStringConvertible {
    
    //cases
    case Cycle5 = 0, Cycle3, Cycle531, Deload
    
    //names for printing
    static let cycleNames = [
        Cycle5 : "5 Reps Cycle",
        Cycle3 : "3 Reps Cycle",
        Cycle531 : "5-3-1 Reps Cycle",
        Deload : "Deload Cycle"
    ]
    
    //description var for allows for CustomStringConvertibe conformance
    var description: String {
        get {
            guard let name = WorkoutCycle.cycleNames[self] else {
                return "Workout Cycle"
            }
            return name
        }
    }
}