//
//  UdacityConvenience.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    // MARK: - Authentication
    
    /* Steps:
    1. POSTing (Creating) a Session
    2. GETting Public User Data
    */
    
    func authenticateAndGetUserData(hostViewController: UIViewController, username: String, password: String, completionHandler: (success: Bool, uniqueKey: String?, userData: UdacityUser?, errorString: String?) -> Void) {
        
        // Chain completion handlers for each request so that they run one after the other
        
        // 1. POSTing (Creating) a Session
        postSession(username, password: password) { (success, uniqueKey, errorString) in
            
            if success {
                // 2. GETting Public User Data
                self.getPublicUserData(uniqueKey) { (success, uniqueKey, userData, errorString) in
                    
                    if success {
                        completionHandler(success: true, uniqueKey: uniqueKey, userData: userData, errorString: nil)
                    } else {
                        completionHandler(success: false, uniqueKey: uniqueKey, userData: nil, errorString: errorString)
                    }
                    
                }
            } else {
                completionHandler(success: false, uniqueKey: nil, userData: nil, errorString: errorString)
            }
        }
    }
    
    func postSession(username: String, password: String, completionHandler: (success: Bool, uniqueKey:String?, errorString: String?) -> Void) {
        
        // 1. Specify parameters, method
        let parameters = [String: String]()
        let mutableMethod : String = Methods.Session
        let jsonBody: [String: [String: String]] = [ "udacity": [
            UdacityClient.JSONBodyKeys.Username: username,
            UdacityClient.JSONBodyKeys.Password: password
            ]
        ]
        
        // 2. Make the request
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, uniqueKey: nil, errorString: error.localizedDescription)
            } else {
                if let _ = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? [String: AnyObject] {
                    if let resultsForAccount = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? [String: AnyObject] {
                        if resultsForAccount[UdacityClient.JSONResponseKeys.Registered] as! Int == 1 {
                            let key = resultsForAccount[UdacityClient.JSONResponseKeys.Key] as! String
                            completionHandler(success: true, uniqueKey: key, errorString: nil)
                        }
                    }
                } else {
                    completionHandler(success: false, uniqueKey: nil, errorString: "Invalid Email or Password.")
                }
            }
        }
        
    }
    
    func getPublicUserData(uniqueKey: String?, completionHandler:(success: Bool, uniqueKey: String?, userData: UdacityUser?, errorString: String?) -> Void) {
        
        // 1. Specify parameters, method (if has {key})
        let parameters = [String: String]()
        var mutableMethod: String = Methods.UserId
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(uniqueKey!))!
        
        // 2. Make the request
        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, uniqueKey: uniqueKey, userData: nil, errorString: error.localizedDescription)
            } else {
                if let resultsForUser = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? [String: AnyObject] {
                    if let resultsForFirstName = resultsForUser[UdacityClient.JSONResponseKeys.FirstName] as? String,
                        let resultsForAccountLastName = resultsForUser[UdacityClient.JSONResponseKeys.LastName] as? String {
                            let userData = UdacityUser(firstName: resultsForFirstName, lastName: resultsForAccountLastName)
                            completionHandler(success: true, uniqueKey: uniqueKey, userData: userData, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, uniqueKey: uniqueKey, userData: nil, errorString: "Unable to get user data.")
                }
            }
        }
        
    }
    
    func deleteSession() {
        
        // 1. Specify parameters, method
        let parameters = [String: String]()
        let mutableMethod : String = Methods.Session
        
        // 2. Make the request
        taskForDELETEMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let _ = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? [String: AnyObject] {
                    /* println("****************************")
                    println("Deleting the session")
                    println(resultsForSesion)
                    println("****************************") */
                } else {
                    // println("Unable to delete the session.")
                }
            }
        }
        
    }
    
}