//
//  WorkoutManagerClient.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/15/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation

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
    
    //logs in user
    func login(username: String, password: String) {
        print(username)
        print(password)
    }
    
    //signs up user for Workout Manager
    func signUp(username: String, password: String) {
        print(username, "is attempting to signup")
        print(username, "wishes to use", password, "for their password")
    }
}