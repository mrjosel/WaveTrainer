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
    func taskForGETRequest(_ urlString: String, completionHandler: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        //construct URL
        let url = URL(string: urlString)
        
        //create session
        let session = URLSession.shared
        
        //create request
        let request = URLRequest(url: url!)
        
        //create handler for task
        let handler = {(data: Data?, urlResponse: URLResponse?, error: NSError?) -> Void in
            
            //check for error
            if let error = error {
                completionHandler(false, nil, error)
            } else {
                //no error, successful request, get data
                //TODO:  PARSE JSON FUNCTION
            }
        }
        
        //start task and return
        let task = session.dataTask(with: request, completionHandler: handler as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
        return task
    }
}
