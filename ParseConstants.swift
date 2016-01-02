//
//  ParseConstants.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

extension ParseClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: Parse App ID & REST key
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseURL: String = "http://api.parse.com/1/classes/StudentLocation?order=-updatedAt"
        static let BaseURLSecure: String = "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Session
        static let ObjectId = "objectId"
        
    }
    
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let Lastname = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UdacityURL = "https://udacity.com"
        
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let Results = "results"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        
    }
    
    
}