//
//  UdacityConstants.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: Udacity Facebook App ID
        static let FacebookAppID: String = "365362206864879"
        
        // MARK: URLs
        static let BaseURL: String = "http://www.udacity.com/api/"
        static let BaseURLSecure: String = "https://www.udacity.com/api/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "session"
        
        // MARK: Public user data
        static let UserId = "users/{id}"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Username = "username"
        static let Password = "password"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Account - session
        static let Session = "session"
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        
        // Mark: User Data
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
    }
}

