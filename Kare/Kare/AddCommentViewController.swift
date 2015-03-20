//
//  AddCommentViewController.swift
//  Kare
//
//  Created by Josh Lopez on 3/16/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit


class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var commentInputBodyField: UITextView!
    
    var currentUser = PFUser.currentUser()
    var objectID: String!
    
    
    
    
    @IBAction func cancelButton(sender: UIButton) {
        self.commentInputBodyField.resignFirstResponder()
        // Go to story detail view
        self.dismissViewControllerAnimated(true, completion: nil)
        println("cancel comment")
    }
    
    
    
    
    @IBAction func addComentButton(sender: UIButton) {
        println("story id: \(self.objectID)")
        
        var userComment = PFObject(className:"Comment")
        userComment["commentBody"] = commentInputBodyField.text
        userComment["username"] = PFUser.currentUser()
        
        userComment.saveInBackgroundWithBlock{(success: Bool!, error: NSError!) -> Void in
            
            if success == false {
                
                self.displayAlert("Could Not Add Comment", error: "Please Try Again Later.")
                
            } else {
                
                // get story class
                var story = PFObject(withoutDataWithClassName: "Story", objectId: self.objectID) // PFObject(withoutDataWithObjectId: self.objectID)
                println("story: \(story)")

                var PFRelation = story.relationForKey("comments")
                var addRelation = userComment
                PFRelation.addObject(addRelation)
                story.saveInBackground()
                
                self.displayAlert("Comment Added!", error: "Your comment has been added successfully!")
                
                println("added comment successfully")
                
                self.commentInputBodyField.resignFirstResponder()
                
            }
        }
        
    }
    
    
    
    
    // Function to show basic alert controller
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.commentInputBodyField.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.commentInputBodyField.resignFirstResponder()
    }
    
    
    
    
    // animates moving of the view
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    
    
    
    // moves viewcontroller up when editing body input field
    func textViewDidBeginEditing(commentInputBodyField: UITextView) {
        animateViewMoving(true, moveValue: 100)
    }
    
    func textViewDidEndEditing(commentInputBodyField: UITextView) {
        animateViewMoving(false, moveValue: 100)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        commentInputBodyField.delegate = self
        
        commentInputBodyField.layer.cornerRadius = 5
        commentInputBodyField.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        commentInputBodyField.layer.borderWidth = 0.5
        commentInputBodyField.clipsToBounds = true
        
        containerView.layer.cornerRadius = 5
        containerView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        containerView.layer.borderWidth = 2
        containerView.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
