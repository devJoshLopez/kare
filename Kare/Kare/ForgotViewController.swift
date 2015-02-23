//
//  ForgotViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/18/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet var forgottenEmailField: UITextField!
    
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.forgottenEmailField.resignFirstResponder()

    }
    
    // submit to parse.com when return key touched
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == forgottenEmailField) {
            
            sendPasswordResetButton(forgottenEmailField)
            
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
    
    
    
    
    @IBAction func sendPasswordResetButton(sender: AnyObject) {
        
        var error = ""
        
        if forgottenEmailField.text == "" {
            
            error = "Email field is required"
            
        }
        
        if error != "" {
            
            displayAlert("Could Not Complete Task", error: error)
            
        } else {

            PFUser.requestPasswordResetForEmailInBackground(forgottenEmailField.text)
            println("Password Reset Email Sent")
            
            // Go back to story list view
            self.navigationController?.popToRootViewControllerAnimated(true)
            
        }
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set the view controller as the delegate for the username textfield
        self.forgottenEmailField.delegate = self
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
