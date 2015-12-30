//
//  ParseConvenience.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension ParseClient {
    
    func getStudentLocations(completionHandler: (success: Bool, studentLocations: [StudentLocation]?, errorString: String?) -> Void) {
        
        // 1. Specify parameters, methods
        let parameters = [String: String]()
        let mutableMethod = ""
        
        // 2. Make the request
        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, studentLocations: nil, errorString: error.localizedDescription)
            } else {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    let studentsLocations = StudentLocation.studentsLocationsFromResults(results)
                    completionHandler(success: true, studentLocations: studentsLocations, errorString: nil)
                } else {
                    completionHandler(success: false, studentLocations: nil, errorString: "Unable to get students locations.")
                }
            }
        }
        
    }
    
    
    func postStudentLocation(userData: StudentLocation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // 1. Specify parameters, method
        let parameters = [String: String]()
        let mutableMethod  = ""
        let jsonBody: [String: AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: userData.uniqueKey,
            ParseClient.JSONBodyKeys.FirstName: userData.firstName,
            ParseClient.JSONBodyKeys.Lastname: userData.lastName,
            ParseClient.JSONBodyKeys.MapString: userData.mapString,
            ParseClient.JSONBodyKeys.MediaURL: userData.mediaURL,
            ParseClient.JSONBodyKeys.Latitude: userData.latitude,
            ParseClient.JSONBodyKeys.Longitude: userData.longitude,
        ]
        
        // 2. Make the request
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                if let _ = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Failed to Post Location.")
                }
            }
        }
        
    }
    
}