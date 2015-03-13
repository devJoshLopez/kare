//
//  StoryDetailViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/12/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class StoryDetailViewController: UIViewController {
    
    @IBOutlet var storyLoveDetail: UILabel!
    @IBOutlet var storyCommentsCountDetail: UILabel!
    @IBOutlet var storyTitleDetail: UILabel!
    @IBOutlet var storyAuthorDetail: UILabel!
    @IBOutlet var comboDistanceDatestampDetail: UILabel!
    @IBOutlet var storyImageDetail: UIImageView!
    @IBOutlet var storyBodyTextDetail: UITextView!
    @IBOutlet var storyDetailToolbar: UIToolbar!
    
    var queryStoryDetailData:NSMutableArray = NSMutableArray()
    
    var objectID: String!
    
    var currentUser = PFUser.currentUser()
    
    @IBAction func addHeartButton(sender: AnyObject) {
        
        // query the story
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
                        println("added user to storyLove")
                    } else if storyLove.containsObject(currentUserId) {
                        storyLove.removeObject(currentUserId)
                        println("removed user from storyLove")
                    }
                    story.saveInBackground()
                    story.fetch()
                    self.storyLoveDetail.text = String(storyLove.count - 1)
                }
            }
        }
        
    }
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
