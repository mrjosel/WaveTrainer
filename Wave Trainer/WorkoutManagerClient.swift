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
    case noBarWeightSet
}

//class that handles Workout Manager Client
class WorkoutManagerClient: AnyObject {
    
    //singleton
    static let sharedInstance = WorkoutManagerClient()
    
    //prevents developers from initializing Workout Manager in app
    fileprivate init() {}
    
    //static constants for client
    struct Constants {
        static let API_KEY = "4b15f2ad2aa8285971ec064bcde0aca67b08d3ae"
        static let ROOT_URL = "https://wger.de"
        static let API_WIDE = "/api/v2"
    }
    
    //parameters used in url
    struct Params {
        static let SEARCH = "search"
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
        static let LANGUAGE = "language"
        static let STATUS = "status"
        static let ORDERING = "ordering"
        static let TERM = "term"
        static let FORMAT = "format"
        static let RESULTS = "results"
        static let NAME = "name"
        static let DESCRIPTION = "description"
        static let FULL_NAME = "full_name"
        static let CATEGORY = "category"
        static let IMAGE = "image"
        static let SUGGESTIONS = "suggestions"
        static let VALUE = "value"
        static let DATA = "data"
        
    }
    
    //categories of exercises
    struct CoreCategories {
        static let SHOULDERS = "Shoulders"
        static let BACK = "Back"
        static let CHEST = "Chest"
        static let LEGS = "Legs"
    }
    
    //values of interest
    struct Values {
        static let ENGLISH_TEXT = "English"
        static let ENGLISH_NUM = "2"
        static let OFFICIAL_STATUS = "2"
        static let JSON = "json"
    }
    
    //plates available for useage
    struct PlatesAvailable {
        static let FORTYFIVE = "45.0"
        static let TWENTYFIVE = "25.0"
        static let TEN = "10.0"
        static let FIVE = "5.0"
        static let TWOPOINTFIVE = "2.5"
        static let ALLPLATES : [String] = [PlatesAvailable.FORTYFIVE, PlatesAvailable.TWENTYFIVE, PlatesAvailable.TEN, PlatesAvailable.FIVE, PlatesAvailable.TWOPOINTFIVE]
    }
    
    //placeholder for barWeight and oneRepMax weights
    static let barWeightPlaceHolder = "Enter a weight between 1 - 99.9 lbs"
    static let oneRepMaxPlaceHolder = "Enter test weight"
    
    //variable set by user to denote whether a deload cycle is to be used or not
    var deload : Bool?               //MUST BE ADDED TO NSUSERDEFUALTS
    
    //available plate options for calculating plates on bars, empty until user creates
    var platesSelected = [Double]() {
        //if set, update NSUserDefaults
        didSet {
            UserDefaults.standard.setValue(platesSelected, forKey: "platesSelected")
        }
    }
    
    //bar weight, set by user
    var barWeight : Double? {
    
        //if set, update NSUserDefaults
        didSet {
            UserDefaults.standard.setValue(barWeight, forKey: "barWeight")
        }
    }
    
    //one rep maxes, set by user
    var oneRepMaxes = [String : Int]() {
        //if set, update NSUserDefaults
        didSet {
            UserDefaults.standard.setValue(oneRepMaxes, forKey: "oneRepMaxes")
        }
    }
    
    //plate calculator function, using barWeight and plates and target weight, returns array of plates required for ONE SIDE OF BARBELL
    //output is always assuming unlimited number of plates for each available weight, therefore output is always comprised of largest available plates
    func plateCalc(_ targetWeight: Double) throws -> [Double] {
        
        //ensure a barWeight is set
        guard let barWeight = self.barWeight else {
            //no bar weight, return
            throw PlateError.noBarWeightSet
        }
        
        //check if targetWeight is greater than barWeight
        guard targetWeight >= barWeight else {
            //throw error
            throw PlateError.weightLessThanBar
        }
        
        //check if targetWeight can be calculatd from barWeight and available plates
        guard (targetWeight - barWeight).truncatingRemainder(dividingBy: platesSelected.last!) == 0 else {
            //throw error
            throw PlateError.ivalidWeight
        }
        
        //remainder variable - get the weight that needs to be placed on one side of barbell, remove largest possible plate from remainder, continue iteration
        var remainder = (targetWeight - barWeight) / 2
        
        //returned result
        var result : [Double] = []
        
        //if remainder is already zero, throw EmptyBar
        guard remainder != 0 else {
            throw PlateError.emptyBar
        }
        
        //calculate plates
        for plate in self.platesSelected {
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
    func taskToFetchExercises(searchString: String, completionHandler : @escaping CompletionHandler) -> URLSessionTask {
        
        //format searchString for proper use in HTTPS
        let httpsSearchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        //need to build URL to use in GET request
        let baseURL = WorkoutManagerClient.Constants.ROOT_URL + WorkoutManagerClient.Constants.API_WIDE
        
        //this task is a search, so the search param is appended after the endpoint by /
        let searchURL = baseURL + "/" + WorkoutManagerClient.Endpoints.EXERCISE + "/" + WorkoutManagerClient.Params.SEARCH
        
        //use searchURL, only english language (for now), and only officially documented exercises
        var mutableParams : [String: String] = [
            WorkoutManagerClient.Keys.FORMAT : WorkoutManagerClient.Values.JSON,
            WorkoutManagerClient.Keys.LANGUAGE : WorkoutManagerClient.Values.ENGLISH_NUM,
            WorkoutManagerClient.Keys.STATUS : WorkoutManagerClient.Values.OFFICIAL_STATUS,
            ]
        
        //if https formatting of search string completes without returning nil, create dict for search term and add to mutableParms
        if let httpsSearchString = httpsSearchString {
            mutableParams[WorkoutManagerClient.Keys.TERM] = httpsSearchString
        }
        
        //create url from searchURL and mutable params
        let urlString = self.createURL(searchURL, params: mutableParams)
        
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
    
    //function takes in base URL string and parameters to create whole URL string
    func createURL(_ baseURLstring : String, params: [String: String]) -> String {
        
        //first append ? to end of baseURLstring
        var outputString = baseURLstring + "?"
        
        //all remainging parameters are appened to the string in the format of &key=value
        for (key, val) in params {
            outputString += "&" + key + "=" + val
        }
        return outputString
        
    }
    
    //takes in Swift dictionary from JSON and returns sorted exercise objects array
    class func makeExercisesFromJSON(jsonData : [String: AnyObject], context: NSManagedObjectContext) -> [Exercise] {
        
        //exercises stored under "results"
        guard let jsonArray = jsonData[WorkoutManagerClient.Keys.SUGGESTIONS] as? [[String: AnyObject]] else {
            //nothing in dict, return empty array
            return [Exercise]()
        }
        
        //map array of dicts into exercise objects
        let excercises : [Exercise] = jsonArray.map() {
            Exercise(dict: $0, reps: nil, order: nil, context: context)!
        }
        return excercises
    }
    
    //update UserDefaults
    func getDefaults() {
        //get defaults for values that are stored in defaults
        let barWeight = UserDefaults.standard.value(forKey: "barWeight") as? Double
        let deload = UserDefaults.standard.value(forKey: "deload") as? Bool
        let plates = UserDefaults.standard.value(forKey: "platesSelected") as? [Double]
        let oneRepMaxes = UserDefaults.standard.value(forKey: "oneRepMaxes") as? [String: Int]
        
        //set values
        WorkoutManagerClient.sharedInstance.barWeight = barWeight
        WorkoutManagerClient.sharedInstance.deload = deload
        WorkoutManagerClient.sharedInstance.platesSelected = plates ?? [Double]()
        WorkoutManagerClient.sharedInstance.oneRepMaxes = oneRepMaxes ?? [String: Int]()
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
