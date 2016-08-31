//
//  WorkoutManagerClient.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/15/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation

//enum for error in plate calculation
enum PlateError : ErrorType {
    case WeightLessThanBar
    case IvalidWeight
    case EmptyBar
}

//class that handles Workout Manager Client
class WorkoutManagerClinet: AnyObject {
    
    //singleton
    static let sharedInstance = WorkoutManagerClinet()
    private init(){}    //prevents developers from initializing Workout Manager in app
    
    //static constants for client
    struct Constants {
        static let API_KEY = "4b15f2ad2aa8285971ec064bcde0aca67b08d3ae"
        static let ROOT_URL = "https://wger.de"
        static let API_WIDE = "api/v2"
    }
    
    //enpoints for client, not all endpoints from API are listed here, only those pertinent to app
    struct Endpoints {
        static let EXERCISE = "exercise"
        static let EXERCISE_CATEGORY = "exercisecategory"
        static let EXERCISE_IMAGE = "exerciseimage"
        //TODO:  GET MORE RELEVANT ENDPOINTS
    }
    
    //available plate options for calculating plates on bars, empty until user creates
    var plates : [Double] = [] {
        didSet {
            //if plates change, perform assending sort
            plates = plates.sort(>)
        }
    }
    
    //bar weight, set by user
    var barWeight : Double = 0
    
    //plate calculator function, using barWeight and plates and target weight, returns array of plates required for ONE SIDE OF BARBELL
    //output is always assuming unlimited number of plates for each available weight, therefore output is always comprised of largest available plates
    func plateCalc(targetWeight: Double) throws -> [Double] {
        
        //check if targetWeight is greater than barWeight
        guard targetWeight >= self.barWeight else {
            //throw error
            throw PlateError.WeightLessThanBar
        }
        
        //check if targetWeight can be calculatd from barWeight and available plates
        guard (targetWeight - self.barWeight) % plates.last! == 0 else {
            //throw error
            throw PlateError.IvalidWeight
        }
        
        //remainder variable - get the weight that needs to be placed on one side of barbell, remove largest possible plate from remainder, continue iteration
        var remainder = (targetWeight - self.barWeight) / 2
        
        //returned result
        var result : [Double] = []
        
        //if remainder is already zero, throw EmptyBar
        guard remainder != 0 else {
            throw PlateError.EmptyBar
        }
        
        //calculate plates
        for plate in self.plates {
            //as long as remainder is greater than the current plate, subtract the plate and append it to result
            while remainder >= plate {
                result.append(plate)
                remainder -= plate
            }
        }
        
        //return array of plates
        return result
    }
    
    //----------
    //FUTURE: CLOUD BASED SHARING POSSIBLE, MAY INVOLVE MIGRATION TO BaaS TYPE FRAMEWORK
    //logs in user
    func login(username: String, password: String) {
        print(username)
        print(password)
    }
    //----------
}