//
//  WorkoutManagerClient.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/15/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

//enum for error in plate calculation
enum PlateError : Error {
    case weightLessThanBar
    case ivalidWeight
    case emptyBar
}

//class that handles Workout Manager Client
class WorkoutManagerClient: AnyObject {
    
    //singleton
    static let sharedInstance = WorkoutManagerClient()
    fileprivate init(){}    //prevents developers from initializing Workout Manager in app
    
    //static constants for client
    struct Constants {
        static let API_KEY = "4b15f2ad2aa8285971ec064bcde0aca67b08d3ae"
        static let ROOT_URL = "https://wger.de"
        static let API_WIDE = "api/v2"
        static let FORMAT = "format"
        static let JSON = "json"
    }
    
    //enpoints for client, not all endpoints from API are listed here, only those pertinent to app
    struct Endpoints {
        static let EXERCISE = "exercise"
        static let EXERCISE_CATEGORY = "exercisecategory"
        static let EXERCISE_IMAGE = "exerciseimage"
        //TODO:  GET MORE RELEVANT ENDPOINTS
    }
    
    //keys to search through JSON data
    struct Keys {
        static let RESULTS = "results"
        static let NAME = "name"
        static let DESCRIPTION = "description"
    }
    
    //variable set by user to denote whether a deload cycle is to be used or not, default is false
    var deload : Bool = false               //MUST BE ADDED TO NSUSERDEFULATS
    
    //available plate options for calculating plates on bars, empty until user creates
    var plates : [Double] = [] {
        didSet {
            //if plates change, perform assending sort
            plates = plates.sorted(by: >)   //MUST BE ADDED TO NSUSERDEFULATS
        }
    }
    
    //bar weight, set by user
    var barWeight : Double = 0              //MUST BE ADDED TO NSUSERDEFULATS
    
    //plate calculator function, using barWeight and plates and target weight, returns array of plates required for ONE SIDE OF BARBELL
    //output is always assuming unlimited number of plates for each available weight, therefore output is always comprised of largest available plates
    func plateCalc(_ targetWeight: Double) throws -> [Double] {
        
        //check if targetWeight is greater than barWeight
        guard targetWeight >= self.barWeight else {
            //throw error
            throw PlateError.weightLessThanBar
        }
        
        //check if targetWeight can be calculatd from barWeight and available plates
        guard (targetWeight - self.barWeight).truncatingRemainder(dividingBy: plates.last!) == 0 else {
            //throw error
            throw PlateError.ivalidWeight
        }
        
        //remainder variable - get the weight that needs to be placed on one side of barbell, remove largest possible plate from remainder, continue iteration
        var remainder = (targetWeight - self.barWeight) / 2
        
        //returned result
        var result : [Double] = []
        
        //if remainder is already zero, throw EmptyBar
        guard remainder != 0 else {
            throw PlateError.emptyBar
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
    
    //gets exercises from Workout Manager
    func taskToFetchExercises(completionHandler : @escaping CompletionHandler) -> URLSessionTask {
        
        //TODO:  BETTER UNDERSTAND URL STRING CREATION
        let urlString = "https://wger.de/api/v2/exercise/?format=json"
        //create search task based on search text
        let searchTask = WorkoutManagerClient.sharedInstance.taskForGETRequest(urlString, completionHandler:  {data, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                //no error, pass data into JSON parser
                WorkoutManagerClient.parseJSONWithCompletionHandler(data as! Data, completionHandler: {parsedJSON, error in
                    
                    //check for error, if so return
                    if let error = error {
                        //complete with error
                        completionHandler(nil, error)
                    } else {
                        //no error, complete and return parsedJSON 
                        completionHandler(parsedJSON, nil)
                    }
                })
                
            }
        })
        //resume task to actually kick it off, return running task
        searchTask.resume()
        return searchTask
    }
    
    //takes in Swift dictionary from JSON and returns sorted exercise objects array
    class func makeExercisesFromJSON(jsonData : [String: AnyObject], context: NSManagedObjectContext) -> [Exercise] {
        
        //exercises stored under "results"
        guard let exerciseDict = jsonData[WorkoutManagerClient.Keys.RESULTS] as? [[String: AnyObject]] else {
            //nothing in dict or failed to cast, return nil
            return []
        }
        
        //map array of dicts into exercise objects
        let excercises : [Exercise] = exerciseDict.map() {
            Exercise(dict: $0, isCore: false, reps: nil, order: nil, context: context)!
        }
        return excercises
    }
    
    //----------
    //FUTURE: CLOUD BASED SHARING POSSIBLE, MAY INVOLVE MIGRATION TO BaaS TYPE FRAMEWORK
    //logs in user
    func login(_ username: String, password: String) {
        print(username)
        print(password)
    }
    //----------
}
