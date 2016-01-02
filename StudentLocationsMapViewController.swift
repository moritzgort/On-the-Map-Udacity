//
//  StudentLocationsMapViewController.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    // Varaibles to hold the user data & unique key
    var userData: UdacityUser!
    var uniqueKey: String!
    
    var savedStudents = SavedStudents()
    
    // Variable to hold the old annotations
    var oldAnnotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        loadStudentLocations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the right bar buttons
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
        let pinButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "openInformationPostingView")
        self.navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // Add observer to the refresh notification
        subscribeToRefreshNotifications()
        
        blackView.hidden = false
        activityIndicator.startAnimating()
        
        // Populate the userData & uniqueKey with the data from the login scene
        userData = savedStudents.udacityUserData
        uniqueKey = savedStudents.userUniqueID
        
        loadStudentLocations()
        
    }
    
    @IBAction func logoutButton(sender: UIBarButtonItem) {
        // Clear the user data saved in the app delegate
        savedStudents.udacityUserData = nil
        savedStudents.userUniqueID = nil
        
        UdacityClient.sharedInstance().deleteSession()
        
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshStudentLocations() {
        loadStudentLocations()
    }
    
    func openInformationPostingView() {
        
        // Prepare a URL to use on checking for network availability
        let url = NSURL(string: "https://www.google.com")!
        let data = NSData(contentsOfURL: url)
        
        // If there's a network connection available, open the information posting view controller
        if data != nil {
            // Open the information posting view
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewConroller")
            presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    func loadStudentLocations() {
        
        // Remove the previous annotaions
        mapView.removeAnnotations(oldAnnotations)
        
        blackView.hidden = false
        activityIndicator.startAnimating()
        
        ParseClient.sharedInstance().getStudentLocations() { (success, StudentsLocations: [StudentLocation]?, errorString) in
            
            if success {
                if let StudentsLocations = StudentsLocations {
                    // Save the students locations to the app delegate
                    self.savedStudents.studentsLocations = StudentsLocations
                    
                    // Notify the other tabs to reload their ceels
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyOtherTabsToReloadCells()
                    }
                    
                    // Annotate the map view with the locations
                    self.annotateTheMapWithLocations()
                }
            } else {
                // Display an alert with the error for the user
                self.displayError(errorString)
                // Shutdown the black view & the activity indicator
                dispatch_async(dispatch_get_main_queue()) {
                    self.blackView.hidden = true
                    self.activityIndicator.stopAnimating()
                }
                
            }
            
        }
        
        
    }
    
    func notifyOtherTabsToReloadCells() {
        // Notify the Table and the Collection tabs to reload their cells
        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationCenterKeys.DataIsReloadedSuccessfully, object: self)
    }
    
    func annotateTheMapWithLocations() {
        
        let locations = savedStudents.studentsLocations!
        // Create MKPointAnnotation for each dictionary in "locations".
        var annotations = [MKPointAnnotation]()
        
        for studentLocation in locations {
            
            // The latitude and longitude are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
            
            let first = studentLocation.firstName
            let last = studentLocation.lastName
            let mediaURL = studentLocation.mediaURL
            
            // Create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // Save the annotations to be able to remove it on updating the map.
        oldAnnotations = annotations
        
        dispatch_async(dispatch_get_main_queue()) {
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
            
            // Shutdown the black view & the activity indicator.
            self.blackView.hidden = true
            
        }
        
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            // Prepare the Alert view controller with the error message to display
            let alert = UIAlertController(title: "", message: errorString, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(dismissAction)
            dispatch_async(dispatch_get_main_queue(), {
                // Display the Alert view controller
                self.presentViewController (alert, animated: true, completion: nil)
            })
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Create a view with a "right callout accessory view".
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    /* This delegate method is implemented to respond to taps. It opens the system browser
    to the URL specified in the annotationViews subtitle property. */
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: annotationView.annotation!.subtitle!!)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
            } else {
                displayError("Invalid Link")
            }
        }
    }
    
    
}

extension StudentLocationsMapViewController {
    
    func subscribeToRefreshNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStudentLocations", name: NSNotificationCenterKeys.RefreshButtonIsRealeasedNotification, object: nil)
    }
    
    /* func unsubscribeToRefreshNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationCenterKeys.RefreshButtonIsRealeasedNotification, object: nil)
    } */
    
}
