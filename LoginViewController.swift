//
//  LoginViewController.swift
//  On the Map 2
//
//  Created by Moritz Gort on 30/12/15.
//  Copyright © 2015 Gabriele Gort. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign the textfields to  delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Configure the UI
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        addKeyboardDismissRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        // So email and password fields are empty again on logging out
        emailTextField.text = ""
        passwordTextField.text = ""
        
        removeKeyboardDismissRecognizer()
    }
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        // Attempt login only if there's an e-mail & a password
        if !(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty) {
            UdacityClient.sharedInstance().authenticateAndGetUserData(self, username: emailTextField.text!, password: passwordTextField.text!) { (success, uniqueKey: String?, userData: UdacityUser?, errorString) in
                
                if success {
                    if let uniqueKey = uniqueKey,
                        let userData = userData {
                            self.completeLogin(uniqueKey, userData: userData)
                    }
                } else {
                    var newErrorString = errorString
                    // If the status code == 403: status text: "Forbidden", description: "Client does not have access rights to the content so server is rejecting to give proper response."
                    if ((newErrorString?.containsString("403")) != nil) {
                        newErrorString = "Invalid Email or Password."
                    }
                    self.displayError(newErrorString)
                }
                
            }
            
        } else {
            self.displayError("Empty Email or Password.")
        }
    }
    
    func completeLogin(uniqueKey: String, userData: UdacityUser) {
        
        // Save the user data & its unique id to the app delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).udacityUserData = userData
        (UIApplication.sharedApplication().delegate as! AppDelegate).userUniqueID = uniqueKey
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentsLocationsTabbedBar") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
        
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            // Prepare the Alert view controller with the error message to display
            let alert = UIAlertController(title: "", message: errorString, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(dismissAction)
                // Display the Alert view controller
                self.presentViewController (alert, animated: true, completion: nil)
            }
        }
    
    @IBAction func signUpForUdacity(sender: UIButton) {
        // Open a link to the udacity page in safari
        if let requestUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    // MARK: - UI Configurations
    
    func configureUI() {
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
}

