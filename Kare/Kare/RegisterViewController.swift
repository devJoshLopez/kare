//
//  RegisterViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/18/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var registerUsernameField: UITextField!
    @IBOutlet var registerEmailField: UITextField!
    @IBOutlet var registerPasswordField: UITextField!

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.registerUsernameField.resignFirstResponder()
        self.registerEmailField.resignFirstResponder()
        self.registerPasswordField.resignFirstResponder()
        
    }
    
    // go to next textfield on return and for last textfield submit to parse.com
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == registerUsernameField) {
            
            self.registerEmailField.becomeFirstResponder()
            
        } else if (textField == registerEmailField) {
            
            self.registerPasswordField.becomeFirstResponder()
            
        } else if (textField == registerPasswordField) {
            
            registerActionButton(registerPasswordField)
            
        }
        
        return true
    }

    
    
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    

    
    @IBAction func registerActionButton(sender: AnyObject) {
        
        var error = ""
        
        if registerUsernameField.text == "" || registerEmailField.text == "" || registerPasswordField.text == "" {
            
            error = "All fields are required"
        }
        
        if error != "" {
            
            displayAlert("Error In Form", error: error)
            
        } else {
            
            // activity indicator
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // create user for parse.com
            var user = PFUser()
            user.username = registerUsernameField.text
            user.password = registerPasswordField.text
            user.email = registerEmailField.text
                
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool!, signupError: NSError!) -> Void in
                    
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                if signupError == nil  {
                // Hooray! Let them use the app now.
                        
                    println("signed up")
                    
                    // Go to story list view
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    
                    if let errorString = signupError.userInfo?["error"] as? NSString {
                            
                    error = errorString
                            
                } else {
                            
                    error = "Please try again later."
                            
                }
                        
                    self.displayAlert("Could Not Sign Up", error: error)
                        
                }
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set the view controller as the delegate for the username textfield
        self.registerUsernameField.delegate = self
        self.registerEmailField.delegate = self
        self.registerPasswordField.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
