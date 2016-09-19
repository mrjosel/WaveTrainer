//
//  WorkoutManagerREST.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/25/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation


//all REST related functions in extension
extension WorkoutManagerClient {
    
    //alias for completionHandler
    typealias CompletionHandler = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    //HTTP GET REQUEST
    func taskForGETRequest(_ urlString: String, completionHandler : @escaping CompletionHandler) -> URLSessionTask {
        
        //construct URL
        let url = URL(string: urlString)
        
        //create session
        let session = URLSession.shared
        
        //create request
        let request = URLRequest(url: url!)
        
        //start task and return
        let task = session.dataTask(with: request, completionHandler: {data, urlResponse, error in
            
            //check for error
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                //no error, successful request, get data
                completionHandler(data as AnyObject?, nil)
            }
        })
        task.resume()
        return task
    }
    
    //take in NSData and create JSON object
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: @escaping CompletionHandler) {

        //parsed JSON data to return
        var parsedResult : AnyObject?
        
        //attempt parsing of JSON data to creare JSON object
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            //failed to parse data, complete with error
            completionHandler(nil, error as NSError?)
            return
        }
        
        //success, complete with parsedResult
        completionHandler(parsedResult, nil)
    }
}
