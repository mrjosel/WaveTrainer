//
//  WorkoutManagerREST.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/25/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation


//all REST related functions in extension
extension WorkoutManagerClinet {
    
    //HTTP GET REQUEST
    func taskForGETRequest(urlString: String, completionHandler: (success: Bool, result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        //construct URL
        let url = NSURL(string: urlString)
        
        //create session
        let session = NSURLSession.sharedSession()
        
        //create request
        let request = NSURLRequest(URL: url!)
        
        //create handler for task
        let handler = {(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) -> Void in
            
            //check for error
            if let error = error {
                completionHandler(success: false, result: nil, error: error)
            } else {
                //no error, successful request, get data
                //TODO:  PARSE JSON FUNCTION
            }
        }
        
        //start task and return
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
        return task
    }
}