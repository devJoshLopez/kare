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
    
    @IBAction func cancelButton(sender: UIButton) {
        // Go to story detail view
        self.dismissViewControllerAnimated(true, completion: nil)
        println("cancel comment")
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
        println("tada")
        // storyBodyInputField.updateConstraints()
        animateViewMoving(true, moveValue: 100)
    }
    
    func textViewDidEndEditing(commentInputBodyField: UITextView) {
        println("tada2")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
