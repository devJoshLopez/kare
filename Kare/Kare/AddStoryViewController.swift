//
//  AddStoryViewController.swift
//  Kare
//
//  Created by Josh Lopez on 1/17/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import CoreImage
import ImageIO
import AssetsLibrary

var storyId = String()




class AddStoryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate {


    @IBOutlet var storyTitleInputField: UITextField!
    @IBOutlet var storyBodyInputField: UITextView!
    @IBOutlet var pickedImage: UIImageView!
    
    
    var currentUser = PFUser.currentUser()
    
    var currentDeviceLocation = CLLocationManager()
    
    var imageSelected:Bool = false
    
    var imageLocation = PFGeoPoint()
    
    var imageLongitude = Double()
    var imageLatitude = Double()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.storyTitleInputField.resignFirstResponder()
        self.storyBodyInputField.resignFirstResponder()
        
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
    func textViewDidBeginEditing(storyBodyInputField: UITextView) {
        println("tada")
        storyBodyInputField.updateConstraints()
        animateViewMoving(true, moveValue: 225)
    }
    
    func textViewDidEndEditing(storyBodyInputField: UITextView) {
        println("tada2")
        animateViewMoving(false, moveValue: 225)
    }
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locations = \(locations)")
        
        if locations.count > 0 {
            self.currentDeviceLocation.stopUpdatingLocation()
        }
        
        var currentDeviceLocation = locations[0] as CLLocation
        println("currentDeviceLocation = \(currentDeviceLocation)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    
    
    
    // Function to show basic alert controller
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
            self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // Function to show location alert controller
    func displayLocationAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            
            //get current location of user and add to story location
            
            self.imageLocation = PFGeoPoint(latitude: self.currentDeviceLocation.location.coordinate.latitude, longitude: self.currentDeviceLocation.location.coordinate.longitude)
            
            println("imageLocation = \(self.imageLocation)")
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        println("Image Selected")
        imageSelected = true
        // self.pickedImage.alpha = 1
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as UIImage
        self.pickedImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.pickedImage.image = selectedImage
        
        
        let library = ALAssetsLibrary()
        var url: NSURL = info.objectForKey(UIImagePickerControllerReferenceURL) as NSURL
        
        library.assetForURL(url, resultBlock: {
            (asset: ALAsset!) in
            if asset.valueForProperty(ALAssetPropertyLocation) != nil {
                
                // print the location
                // println(asset.valueForProperty(ALAssetPropertyLocation))
                
                var imageAssetLocation = asset.valueForProperty(ALAssetPropertyLocation) as CLLocation
                self.imageLongitude = imageAssetLocation.coordinate.longitude as Double
                self.imageLatitude = imageAssetLocation.coordinate.latitude as Double
                
                // this is showing that it has longitude and latitude
                println("image longitude: \(self.imageLongitude) image latitude: \(self.imageLatitude)")
                
                self.imageLocation = PFGeoPoint(latitude: self.imageLatitude, longitude: self.imageLongitude)
                
            } else {
                
                // TO DO: Need to ask user if no location is found in image if they would like to use current location instead.
                self.displayLocationAlert("Location Required!", error: "We could not find location info in your image. Would you like to use your current location instead?")
                self.currentDeviceLocation.startUpdatingLocation()
            }
            }, failureBlock: {
                (error: NSError!) in
                
                println("Error! \(error)")
                
            }
        )

    }
    
    

    
    // Button to pick story image
    @IBAction func pickImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }


   
    
    @IBAction func sendStoryButton(sender: AnyObject) {
        
        var error = ""
        
        if (imageSelected == false) {
            
            error = "Please select an image."
            
        } else if (self.imageLocation.latitude == 0) {
            
            error = "Locations are required so we can calculate distance for users."
            
        }else if (storyBodyInputField.text == "") {
            
            error = "Please tell everyone your story."
            
        } else if (storyTitleInputField.text == "") {
            
            error = "Please add a Title to your story."
        }
        
        if (error != "") {
            
           displayAlert("Cannot Add Story", error: error)
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // let imageLocation:PFGeoPoint = PFGeoPoint(latitude: imageLatitude, longitude: imageLongitude)
            
            println("latitude: \(imageLatitude) longitude: \(imageLongitude)")
            
            println("imageLocation: \(self.imageLocation)")
            
            // create variable for current user id
            var currentUserId = currentUser.objectId
        
            // Creates a story object to send to parse.com
            var story = PFObject(className:"Story")
            story["storyLove"] = [currentUserId]
            story["storyCommentCount"] = "0"
            story["storyLocation"] = self.imageLocation
            story["storyDistanceFromUser"] = "miles away"
            story["storyFlagCount"] = "0"
            story["username"] = PFUser.currentUser()
            story["storyTitle"] = storyTitleInputField.text
            story["storyBody"] = storyBodyInputField.text
        
            story.saveInBackgroundWithBlock{(success: Bool!, error: NSError!) -> Void in
            
            if success == false {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Could Not Post Story", error: "Please try again later.")
                
            } else {
                
                // add image to parse here
                story["storyImage"] = PFFile(name: "\(story.objectId)-storyimage.jpg", data: UIImageJPEGRepresentation(self.pickedImage.image, 0.5))
                
                println("Image picked ready for parse.com")
                
                story.saveInBackgroundWithBlock{(success: Bool!, error: NSError!) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if success == false {
                        
                        self.displayAlert("Could Not Add Image", error: "Please Try Again Later.")
                        
                    } else {
                        
                        self.displayAlert("Story Added!", error: "Your story has been added successfully!")
                        
                        self.imageSelected = false
                        
                        // self.storyBodyInputField.placeholder = "Share another story...      "
                        self.storyTitleInputField.text = ""
                        self.pickedImage.image = UIImage(named: "Camera Icon")
                        self.pickedImage.contentMode = UIViewContentMode.Center
                        self.storyBodyInputField.text = nil
                        
                        // Go back to story list view
                        // self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        storyId = story.objectId
                        
                        println("added story successfully \(storyId)")
                        
                    }
                }
            }
        }
        
      }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Do any additional setup after loading the view.
        
        currentDeviceLocation.delegate = self
        currentDeviceLocation.desiredAccuracy = kCLLocationAccuracyBest
        currentDeviceLocation.requestWhenInUseAuthorization()
        
        storyBodyInputField.delegate = self
        
        imageSelected = false
        // pickedImage.alpha = 0
        pickedImage.image = UIImage(named: "Camera Icon")
        pickedImage.contentMode = UIViewContentMode.Center
        
        println("Add Story View Did Load")
        
        storyBodyInputField.layer.cornerRadius = 5
        storyBodyInputField.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        storyBodyInputField.layer.borderWidth = 0.5
        storyBodyInputField.clipsToBounds = true
        
        // self.storyBodyInputField.placeholder = "Tell everyone your story...      "
        
        
        }
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
