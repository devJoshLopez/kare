//
//  StoryListViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/12/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit
import Foundation

var deviceLocation = PFGeoPoint()

class StoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var dynamicBarButtonItem: UIBarButtonItem!
    @IBOutlet var storySegmentedControl: UISegmentedControl!
    @IBOutlet var distanceSliderLabel: UILabel!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var storyTableView: UITableView!
    @IBOutlet var loginOrAddButton: UIBarButtonItem!
    @IBOutlet var storyTableViewTopConstraint: NSLayoutConstraint!
    
    var storyListViewData = NSMutableArray()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
    
    
    
    func handleRefresh(control: UIRefreshControl) {
        println("Refreshing")
        
        // reload the story data
        self.loadStoryData()

        
       // refreshControl.endRefreshing()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification:", name:"NotificationIdentifier", object: nil)

        
        self.storyTableView.dataSource = self
        self.storyTableView.delegate = self
        
        // get location of current user
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error != nil {
                NSLog("%@", error)
            } else {
                // do something with the new geoPoint
                deviceLocation = geoPoint
                println("Device Location: \(deviceLocation)")
            }
        }
        
        // reload the story data
        self.loadStoryData()
        
        // pull to refresh
        self.storyTableView.addSubview(refreshControl)
    }
    
    
    
    

    
    
    
    func methodOfReceivedNotification(notification: NSNotification){
        // reload the story data
        dispatch_async(dispatch_get_main_queue(), {
        self.loadStoryData()
        })
    }
    
    
    
    
    // remove all stories and then reload them from parse.com
    func loadStoryData(){
        
        self.storyListViewData.removeAllObjects()
        println("Removed all objects: \(self.storyListViewData.count)")
        
        var findStoryListData = PFQuery(className:"Story")
        
        findStoryListData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if error == nil {
                
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
                println("Reload all objects: \(self.storyListViewData.count)")
                
                self.refreshControl.endRefreshing()
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.storyListViewData.count
        
    }
    
    
    
    
    // Delegate method for storyTableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:StoryListTableViewCell = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath) as StoryListTableViewCell
        
        // hide all cell content so it can fade in
        cell.cellStoryTitle.alpha = 0
        cell.cellStoryImage.alpha = 0
        cell.cellStoryBeats.alpha = 0
        cell.cellStoryCommentsCount.alpha = 0
        cell.cellStoryAuthor.alpha = 0
        cell.cellStoryDistance.alpha = 0
        cell.cellStoryDateAdded.alpha = 0
        
        let story:PFObject = self.storyListViewData.objectAtIndex(indexPath.row) as PFObject
        
        // gets the story title
        cell.cellStoryTitle.text = story.objectForKey("storyTitle") as? String
        
        // gets love count
        var storyLove: AnyObject! = story.objectForKey("storyLove")
        var storyLoveCount = String(storyLove.count - 1)
        cell.cellStoryBeats.text = storyLoveCount
        
        // gets comment count
        // TODO: Need to get the comments count
        println(story.objectForKey("comments"))
        cell.cellStoryCommentsCount.text = "0"
        
        // get story location and get the distance between story and user
        var storyLocation:PFGeoPoint = story.objectForKey("storyLocation") as PFGeoPoint
        
        // gets distance from user
        var locationDistance = Int(deviceLocation.distanceInMilesTo(storyLocation))
        cell.cellStoryDistance.text = "\(locationDistance) miles"
        
        // This gets the author of the story
        var findStoryAuthor: PFQuery = PFUser.query()
        findStoryAuthor.whereKey("objectId", equalTo: story.objectForKey("username").objectId)
        
        findStoryAuthor.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if !(error != nil){
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.cellStoryAuthor.text = "by \(user.username)"

            }
        }
        
        // gets the date the story was submitted
        // TODO: make the date like twitter.
        var storyDateFormatter:NSDateFormatter = NSDateFormatter()
        storyDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.cellStoryDateAdded.text = storyDateFormatter.stringFromDate(story.createdAt)
        
        // gets the storyimage
        let storyImagePreview:PFFile = story["storyImage"] as PFFile
        
        storyImagePreview.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!)->Void in
            
            if !(error != nil){
                let image:UIImage = UIImage(data: imageData)!
                cell.cellStoryImage.image = image
            }
        }
        
        // fade in animation
        UIView.animateWithDuration(0.5, animations: {
            cell.cellStoryTitle.alpha = 1
            cell.cellStoryImage.alpha = 1
            cell.cellStoryBeats.alpha = 1
            cell.cellStoryCommentsCount.alpha = 1
            cell.cellStoryAuthor.alpha = 1
            cell.cellStoryDistance.alpha = 1
            cell.cellStoryDateAdded.alpha = 1
        })
        
        return cell
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