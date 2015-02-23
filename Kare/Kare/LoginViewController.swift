//
//  LoginViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/17/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginUsernameField: UITextField!
    @IBOutlet var loginPasswordField: UITextField!
    
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.loginUsernameField.resignFirstResponder()
        self.loginPasswordField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
     
        if (textField == loginUsernameField) {
         self.loginPasswordField.becomeFirstResponder()
        } else if (textField == loginPasswordField) {
            loginActionButton(loginPasswordField)
        }
        
        return true
    }
    
    
    
    
    @IBAction func loginActionButton(sender: AnyObject) {
        if loginUsernameField.text != "" && loginPasswordField.text != "" {
            // If the Username and Password field ARE NOT empty do...
            
            PFUser.logInWithUsernameInBackground(loginUsernameField.text, password:loginPasswordField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // User DOES exists logs them in and...
                    println("Login Succesful!")
                    
                    // Go back to story list view
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    // User DOES NOT exist
                    println("User Does Not Exist")
                    
                    let loginFailedAlert = UIAlertView()
                    loginFailedAlert.title = "Login Failed"
                    loginFailedAlert.message = "The user does not exist. Please try again or Register for a new account!"
                    loginFailedAlert.addButtonWithTitle("Ok")
                    loginFailedAlert.show()
                    
                }
            }
            
        } else {
            // If the Username and Password field ARE empty do...
            let loginRequiredAlert = UIAlertView()
            loginRequiredAlert.title = "Attention"
            loginRequiredAlert.message = "Username and Password Fields Are Required"
            loginRequiredAlert.addButtonWithTitle("Ok")
            loginRequiredAlert.show()
        }
        
        
    }
    
    
    
    
    @IBAction func registerNewUserButton(sender: AnyObject) {
        println("Send to Register New User")
    }
    
    
    
    
    @IBAction func forgotPasswordButton(sender: AnyObject) {
        println("Send to Forgot Password")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // Set the view controller as the delegate for the username textfield
        self.loginUsernameField.delegate = self
        self.loginPasswordField.delegate = self
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
