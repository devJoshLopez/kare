//
//  StoryDetailViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/12/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class StoryDetailViewController: UIViewController {
    
    @IBOutlet var storyLoveDetail: UILabel!
    @IBOutlet var storyCommentsCountDetail: UILabel!
    @IBOutlet var storyTitleDetail: UILabel!
    @IBOutlet var storyAuthorDetail: UILabel!
    @IBOutlet var comboDistanceDatestampDetail: UILabel!
    @IBOutlet var storyImageDetail: UIImageView!
    @IBOutlet var storyBodyTextDetail: UITextView!
    @IBOutlet var storyDetailToolbar: UIToolbar!
    
    var addCommentViewController = AddCommentViewController()
    
    var queryStoryDetailData:NSMutableArray = NSMutableArray()
    
    var objectID: String!
    
    var currentUser = PFUser.currentUser()
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    
    
    
    
    @IBAction func addHeartButton(sender: AnyObject) {
        
        // query the story
        // TODO: Need to redo this so if the user is the author it doesnt have to keep query the db and waste data
        var queryStoryLove = PFQuery(className:"Story")
        queryStoryLove.getObjectInBackgroundWithId(objectID) {
            (story: PFObject!, error: NSError!) -> Void in
            
            if error != nil {
                NSLog("%@", error)
            } else {

                var currentUserId = self.currentUser.objectId
                var storyAuthor: AnyObject! = story.objectForKey("username")
                var storyLove = story.objectForKey("storyLove") as NSMutableArray
                
                // do not allow the author of the story to love the story
                if currentUserId != storyAuthor.objectId as NSString {
                    
                    println("you are not the author")
                    
                    if !storyLove.containsObject(currentUserId) {
                        
                        storyLove.addObject(currentUserId)
                        
                        // play heartbeat
                        self.audioPlayer.play()
                        
                        println("added user to storyLove")
                        
                    } else if storyLove.containsObject(currentUserId) {
                        
                        storyLove.removeObject(currentUserId)
                        println("removed user from storyLove")

                    }
                    story.saveInBackground()
                    story.fetchInBackground()
                    self.storyLoveDetail.text = String(storyLove.count - 1)
                    
                    // vibrates device, need to find a way to make the device vibrate 2 times like a heartbeat
                    // AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    
                }
            }
        }
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create url path for audio
        let fileLocation = NSString(string:NSBundle.mainBundle().pathForResource("heartbeat", ofType: "wav")!)
        var error: NSError? = nil
        audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: fileLocation), error: &error)
        
        // hide toolbar for users not logged in
        if currentUser == nil {
            storyDetailToolbar.alpha = 0
        }
        
        // query the story to display its information
        var queryStoryDetailData = PFQuery(className:"Story")
        queryStoryDetailData.whereKey("objectId", equalTo: objectID)
        queryStoryDetailData.findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                // The find succeeded.
                println("Successfully retrieved \(objects.count) story.")
                
                // Do something with the found objects
                for object in objects {
                    println("Story retrieved is", object.objectId)
                    
                    let story:PFObject = object as PFObject
                    
                    // gets love count
                    var querystoryLove: AnyObject! = story.objectForKey("storyLove")
                    var storyLoveCount = String(querystoryLove.count - 1)
                    self.storyLoveDetail.text = storyLoveCount
                    
                    // get story location and get the distance between story and user
                    var storyLocation:PFGeoPoint = story.objectForKey("storyLocation") as PFGeoPoint
                    println("Story Location: \(storyLocation)")
                    var locationDistance = Int(deviceLocation.distanceInMilesTo(storyLocation))
                    
                    self.storyCommentsCountDetail.text = story.objectForKey("storyCommentCount") as? String
                    self.storyTitleDetail.text = story.objectForKey("storyTitle") as? String
                    self.comboDistanceDatestampDetail.text = "\(locationDistance) miles away & Datestamp"
                    self.storyTitleDetail.text = story.objectForKey("storyTitle") as? String
                    self.storyBodyTextDetail.text = story.objectForKey("storyBody") as? String
                    
                    // This gets the author of the story
                    var findStoryAuthor: PFQuery = PFUser.query()
                    findStoryAuthor.whereKey("objectId", equalTo: story.objectForKey("username").objectId)
                    
                    findStoryAuthor.findObjectsInBackgroundWithBlock{
                        (objects:[AnyObject]!, error:NSError!) -> Void in
                        
                        if !(error != nil){
                            
                            let user:PFUser = (objects as NSArray).lastObject as PFUser
                            self.storyAuthorDetail.text = "by \(user.username)"
                            
                        }
                    }
                    
                    
                    // gets the storyimage
                    let storyImageDetail:PFFile = story["storyImage"] as PFFile
                    
                    storyImageDetail.getDataInBackgroundWithBlock{
                        (imageData:NSData!, error:NSError!)->Void in
                        
                        if !(error != nil){
                            let image:UIImage = UIImage(data: imageData)!
                            self.storyImageDetail.image = image
                        }
                    }
                    
                    
                }
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCommentSegue" {
            
            presentingViewController?.providesPresentationContextTransitionStyle = true
            presentingViewController?.definesPresentationContext = true
            presentedViewController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            
            var dVC:AddCommentViewController = segue.destinationViewController as AddCommentViewController
            dVC.objectID = objectID
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // TODO: Need to figure out how to reload the data on the storylistviewcontroller when a user touches the back button on this viewcontroller
    // Warning: A long-running operation is being executed on the main thread.
    deinit {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
    }

}
