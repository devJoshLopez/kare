//
//  StoryListViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/12/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit


class StoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var dynamicBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var storySegmentedControl: UISegmentedControl!
    @IBOutlet var distanceSliderLabel: UILabel!
    @IBOutlet var distanceSlider: UISlider!
    
    @IBOutlet var storyTableView: UITableView!
    @IBOutlet var loginOrAddButton: UIBarButtonItem!
    
    @IBOutlet var storyTableViewTopConstraint: NSLayoutConstraint!
   
    var storyListViewData:NSMutableArray = NSMutableArray()
    
    
    // remove all stories and then reload them from parse.com
    func loadStoryData(){
        
        storyListViewData.removeAllObjects()
        
        var findStoryListData = PFQuery(className:"Story")
        
        findStoryListData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if !(error != nil) {
                
                // The query succeeded/
                println("Successfully retrieved \(objects.count) stories.")
                
                // Do something with the found stories
                for object in objects {
                    
                    let story:PFObject = object as PFObject
                    
                    self.storyListViewData.addObject(story)
            }
                
                let array:NSArray = self.storyListViewData.reverseObjectEnumerator().allObjects
                self.storyListViewData = NSMutableArray(array: array)
                
                self.storyTableView.reloadData()
            }
        }
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            // refreshes the layout
            self.view.layoutIfNeeded()
            
            // Do stuff with the user
            dynamicBarButtonItem.title = "Add Story"
            
            // Hide UI if user is not logged in
            storySegmentedControl.alpha = 1
            distanceSliderLabel.alpha = 1
            distanceSlider.alpha = 1
            
            // enlarge constraint
            self.storyTableViewTopConstraint.constant = 90
            
        } else {
            // refreshes the layout
            self.view.layoutIfNeeded()
            
            // Show the signup or login screen
            dynamicBarButtonItem.title = "Login/Register"
            
            // Hide UI if user is not logged in
            storySegmentedControl.alpha = 0
            distanceSliderLabel.alpha = 0
            distanceSlider.alpha = 0
            
            // shorten constraint
            self.storyTableViewTopConstraint.constant = 5
            
        }

    }
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        // reload the story data
        self.loadStoryData()
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storyTableView.dataSource = self
        self.storyTableView.delegate = self
        
    }


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // return the number of sections
        return 1
        
    }
    
    
    
    
    // Delegate method for storyTableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StoryListTableViewCell = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath) as StoryListTableViewCell
        
        let story:PFObject = self.storyListViewData.objectAtIndex(indexPath.row) as PFObject
        
        // gets the story title
        cell.storyTitlePreview.text = story.objectForKey("storyTitle") as? String
        
        // gets love count
        var storyLove = [story.objectForKey("storyLove")]
        var storyLoveCount = String(storyLove.count)
        cell.storyLovePreview.text = storyLoveCount
        
        // gets comment count
        cell.storyCommentsCountPreview.text = story.objectForKey("storyCommentCount") as? String
        
        // gets distance from user
        cell.storyDistancePreview.text = story.objectForKey("storyDistanceFromUser") as? String
        
        // This gets the author of the story
        var findStoryAuthor: PFQuery = PFUser.query()
        findStoryAuthor.whereKey("objectId", equalTo: story.objectForKey("username").objectId)
        
        findStoryAuthor.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if !(error != nil){
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.storyAuthorPreview.text = "by \(user.username)"

            }
        }
        
        // gets the date the story was submitted
        // TODO: make the date like twitter.
        var storyDateFormatter:NSDateFormatter = NSDateFormatter()
        storyDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.storyDatestampPreview.text = storyDateFormatter.stringFromDate(story.createdAt)
        
        // gets the storyimage
        let storyImagePreview:PFFile = story["storyImage"] as PFFile
        
        storyImagePreview.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!)->Void in
            
            if !(error != nil){
                let image:UIImage = UIImage(data: imageData)!
                cell.storyImagePreview.image = image
            }
        }
        
        return cell
    }

    
    
    
    // Delegate method for storyTableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return storyListViewData.count
        
    }
    
    
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }

    
    
    // login/register button
    @IBAction func dynamicBarButtonTouched(sender: AnyObject) {
        if dynamicBarButtonItem.title == "Login/Register" {
            self.performSegueWithIdentifier("LoginSegueIdentifier", sender: self)
            println("Send to Login")
        }
        if dynamicBarButtonItem.title == "Add Story" {
            self.performSegueWithIdentifier("AddStorySegueIdentifier", sender: self)
            println("Send to Add Story")
        }
        
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "storyDetailSegue" {
            
            var dVC:StoryDetailViewController = segue.destinationViewController as StoryDetailViewController
            let indexPath = storyTableView.indexPathForSelectedRow()!.row
            let story:PFObject = storyListViewData.objectAtIndex(indexPath) as PFObject
            // print(storyListViewData)
            dVC.objectID = story.objectId
            
        }
    }

}