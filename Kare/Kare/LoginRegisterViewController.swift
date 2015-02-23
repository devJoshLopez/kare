//
//  LoginViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/17/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class LoginRegisterViewController: UIViewController {
    
    @IBOutlet var loginUsernameField: UITextField!
    @IBOutlet var loginPasswordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginActionButton(sender: AnyObject) {
        if loginUsernameField.text != "" && loginPasswordField.text != "" {
            // If the Username and Password field ARE NOT empty do...
            
            PFUser.logInWithUsernameInBackground(loginUsernameField.text, password:loginPasswordField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // User DOES exists logs them in and...
                    println("User Exists")
                    // Go back to story list view
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
                } else {
                    // User DOES NOT exist so register them
                    println("User Does Not Exist")
                    
                    let registerRequiredAlert = UIAlertView()
                    registerRequiredAlert.title = "Login Failed"
                    registerRequiredAlert.message = "The user does not exist. Please try again or Register for a new account!"
                    registerRequiredAlert.addButtonWithTitle("Ok")
                    registerRequiredAlert.show()
                    
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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
