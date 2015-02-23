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




class AddStoryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    @IBOutlet var storyTitleInputField: UITextField!
    @IBOutlet var storyBodyInputField: UITextView!
    @IBOutlet var pickedImage: UIImageView!
    
    var imageSelected:Bool = false
    
    var imageLongitude = Double()
    var imageLatitude = Double()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    // Dismisses the keyboard if touch event outside the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.storyTitleInputField.resignFirstResponder()
        self.storyBodyInputField.resignFirstResponder()
        
    }
    
    
    
    
    // Function to show alert controller
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
            self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        println("Image Selected")
        imageSelected = true
        self.pickedImage.alpha = 1
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as UIImage
        self.pickedImage.image = selectedImage
        
        let library = ALAssetsLibrary()
        var url: NSURL = info.objectForKey(UIImagePickerControllerReferenceURL) as NSURL
        
        library.assetForURL(url, resultBlock: {
            (asset: ALAsset!) in
            if asset.valueForProperty(ALAssetPropertyLocation) != nil {
                
                // print the location
                // println(asset.valueForProperty(ALAssetPropertyLocation))
                
                var imageAssetLocation = asset.valueForProperty(ALAssetPropertyLocation) as CLLocation
                let imageLongitude = imageAssetLocation.coordinate.longitude as Double
                let imageLatitude = imageAssetLocation.coordinate.latitude as Double
                
                // this is showing that it has longitude and latitude
                println("image longitude: \(imageLongitude) image latitude: \(imageLatitude)")
                
            } else {
                
                // TO DO: Need to ask user if no location is found in image if they would like to use current location instead.
                self.displayAlert("Location Required!", error: "We could not find location info in your image. Would you like to use your current location instead?")
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
            
        } else if (storyBodyInputField.text == "") {
            
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
            
            let imageLocation:PFGeoPoint = PFGeoPoint(latitude: imageLatitude, longitude: imageLongitude)
            
            println("latitude: \(imageLatitude) longitude: \(imageLongitude)")
            
        // NEEDS FIX: The latitude and longitude are being set to 0 for some reason.
            println("imageLocation: \(imageLocation)")
        
            // Creates a story object to send to parse.com
            var story = PFObject(className:"Story")
            story["storyLove"] = "0"
            story["storyCommentCount"] = "0"
            story["storyLocation"] = imageLocation
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
                        
                        self.storyBodyInputField.placeholder = "Share another story...      "
                        self.storyTitleInputField.text = ""
                        self.pickedImage.image = nil
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
            
        imageSelected = false
        pickedImage.alpha = 0
        
        println("Add Story View Did Load")
        
        storyBodyInputField.layer.cornerRadius = 5
        storyBodyInputField.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        storyBodyInputField.layer.borderWidth = 0.5
        storyBodyInputField.clipsToBounds = true
        
        self.storyBodyInputField.placeholder = "Tell everyone your story...      "
        
        }
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
