//
//  ParseClient.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    // Shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. Set the parameters
        let mutableParameters = parameters
        
        // 2/3. Build the URL and configure the request
        let urlString = Constants.BaseURLSecure + method + ParseClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(ParseClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* GUARD: Was there an error? */
            guard (downloadError == nil) else {
                completionHandler(result: nil, error: downloadError)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: '\(response.statusCode)'"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: '\(response)'"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. Set the parameters
        let mutableParameters = parameters
        
        // 2/3. Build the URL and configure the request
        let urlString = Constants.BaseURLSecure + method + ParseClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(ParseClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* GUARD: Was there an error? */
            guard (downloadError == nil) else {
                completionHandler(result: nil, error: downloadError)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: '\(response.statusCode)'"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: '\(response)'"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    // Helper: Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}
