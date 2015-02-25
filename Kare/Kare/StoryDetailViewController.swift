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
    
    var queryStoryDetailData:NSMutableArray = NSMutableArray()
    
    var objectID: String!
    
    var currentUser = PFUser.currentUser()
    
    @IBAction func addHeartButton(sender: AnyObject) {
        
        var queryStoryLove = PFQuery(className:"Story")
        queryStoryLove.getObjectInBackgroundWithId(objectID) {
            (story: PFObject!, error: NSError!) -> Void in
            
            if error != nil {
                NSLog("%@", error)
            } else {

                var currentUserId = self.currentUser.objectId
                var storyLove = story.objectForKey("storyLove") as NSMutableArray
                
                if !storyLove.containsObject(currentUserId) {
                    storyLove.addObject(currentUserId)
                    story.saveInBackground()
                    self.storyLoveDetail.text = String(storyLove.count)
                    println("added user to storyLove")
                } else {
                    storyLove.removeObject(currentUserId)
                    story.saveInBackground()
                    self.storyLoveDetail.text = String(storyLove.count)
                    println(storyLove)
                }
                
                println(currentUserId)
                
            }
        }
        
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        
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
                    var querystoryLove = [story.objectForKey("storyLove")]
                    var storyLoveCount = String(querystoryLove.count)
                    self.storyLoveDetail.text = storyLoveCount
                    
                    self.storyCommentsCountDetail.text = story.objectForKey("storyCommentCount") as? String
                    self.storyTitleDetail.text = story.objectForKey("storyTitle") as? String
                    self.comboDistanceDatestampDetail.text = "Distance & Datestamp"
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
