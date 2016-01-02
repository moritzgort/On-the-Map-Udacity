//
//  StudentLocationsTableViewController.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import UIKit

class StudentLocationsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Varaibles to hold the user data & unique key
    var userData: UdacityUser!
    var uniqueKey: String!
    
    var savedStudents = SavedStudents()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer to the reload notification
        subscribeToReloadNotifications()
        
        // Add the right bar buttons
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
        let pinButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "openInformationPostingView")
        self.navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // Populate the userData & uniqueKey with the data from the login scene
        userData = savedStudents.udacityUserData
        uniqueKey = savedStudents.userUniqueID
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Reload the rows and sections of the table view.
        tableView.reloadData()
    }
    
    @IBAction func logoutButton(sender: UIBarButtonItem) {
        // Clear the user data saved in the app delegate
        userData = nil
        uniqueKey = nil
        
        UdacityClient.sharedInstance().deleteSession()
        
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshStudentLocations() {
        // Notify the Map tab to reload the data
        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationCenterKeys.RefreshButtonIsRealeasedNotification, object: self)
        
        // Reload the rows and sections of the table view.
        tableView.reloadData()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if savedStudents.studentsLocations != nil {
            return savedStudents.studentsLocations!.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicTableCell")! as UITableViewCell
        
        // Set the name and the image
        let student = savedStudents.studentsLocations![indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        // cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Open the media url in safari
        let student = savedStudents.studentsLocations![indexPath.row]
        if let requestUrl = NSURL(string: student.mediaURL) {
            if UIApplication.sharedApplication().canOpenURL(requestUrl) {
                UIApplication.sharedApplication().openURL(requestUrl)
            } else {
                displayError("Invalid Link")
            }
        }
        
        // Deselect the cell
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
}

extension StudentLocationsTableViewController {
    
    func reloadCells() {
        // Reload the rows and sections of the table view.
        tableView.reloadData()
    }
    
    func subscribeToReloadNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCells", name: NSNotificationCenterKeys.DataIsReloadedSuccessfully, object: nil)
    }
    
    /* func unsubscribeToRefreshNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationCenterKeys.RefreshButtonIsRealeasedNotification, object: nil)
    } */
    
}
