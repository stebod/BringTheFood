//
//  ChangeSettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class ChangeSettingsViewController: UIViewController,UINavigationControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AddressCommunicator {

    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var changeAvatarButton: UIButton!

    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Variables populated from prepareForSegue
    var userImage = UIImage()
    var name = String()
    var email = String()
    var phone = String()
    var address = String()
    
    // Observers
    private weak var changeSettingsObserver: NSObjectProtocol!
    private var tapRecognizer:UITapGestureRecognizer!
    private weak var locationAutocompleteObserver:NSObjectProtocol!
    
    // Location autocompleter
    private var locationAutocompleter: LocationAutocompleter?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAvatarButton.layer.cornerRadius = changeAvatarButton.frame.size.width / 2;
        changeAvatarButton.clipsToBounds = true
        changeAvatarButton.layer.borderWidth = 3.0;
        changeAvatarButton.layer.borderColor = UIMainColor.CGColor
        changeAvatarButton.setImage(userImage, forState: .Normal)
        nameTextField.text = name
        emailTextField.text = email
        phoneTextField.text = phone
        addressTextField.text = address
        addressTableView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        locationAutocompleter = LocationAutocompleter(delegate: self)
        // Set tap recognizer on the view
        locationAutocompleteObserver = NSNotificationCenter.defaultCenter().addObserverForName(locationAutocompletedNotificationKey,
            object: locationAutocompleter,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.locationAutocompleterHandler(notification)})
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapOnView:")
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister as notification center observer
        NSNotificationCenter.defaultCenter().removeObserver(locationAutocompleteObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changeAvatarPressed(sender: AnyObject) {
        if( controllerAvailable()){
            displayIOS8ActionSheet()
        } else {
            displayIOS7ActionSheet()
        }
    }
    
    @IBAction func addressOnFocus(sender: UITextField) {
        if(sender.text == "Address"){
            sender.text! = ""
        }
        if(addressTextField.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
        }
    }
    
    @IBAction func addressOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = "Address"
        }
        addressTableView.hidden = true
    }
    
    @IBAction func addressChanged(sender: UITextField) {
        if(sender.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
            addressTableView.hidden = false
        }
    }

    
    @IBAction func applyChangesButtonPressed(sender: UIButton) {
        
    }

    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Handle location autocomplete
    func locationAutocompleterHandler(notification: NSNotification){
        addressTableView.dataSource = locationAutocompleter
        addressTableView.delegate = locationAutocompleter
        addressTableView.hidden = false
        addressTableView.reloadData()
    }
    
    func communicateAddress(address: String!) {
        addressTextField.text = address
        addressTableView.hidden = true
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if(touch.view.isDescendantOfView(addressTableView)){
            return false
        }
        return true
    }
    
    // Check if alert controller is available in the current iOS version
    private func controllerAvailable() -> Bool {
        if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
            return true;
        }
        else {
            return false;
        }
    }
    
    // Action sheet display in iOS8
    private func displayIOS8ActionSheet() -> Void {
        let imageController = UIImagePickerController()
        imageController.editing = false
        imageController.delegate = self;
        
        let alert = UIAlertController(title: "Lets get a picture", message: "Simple Message", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imageController, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                println("Take Photo")
                imageController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imageController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            println("Camera not available")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            println("Cancel Pressed")
        }
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        changeAvatarButton.layer.cornerRadius = changeAvatarButton.frame.size.width / 2;
        changeAvatarButton.clipsToBounds = true
        changeAvatarButton.layer.borderWidth = 3.0;
        changeAvatarButton.layer.borderColor = UIMainColor.CGColor
        // Use smallest side length as crop square length
        var squareLength = min(image.size.width, image.size.height)
        var clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength)
        changeAvatarButton.setImage(UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, clippedRect)), forState: .Normal)
    }
    
    // Action sheet display in iOS7
    private func displayIOS7ActionSheet() -> Void {
        var actionSheet:UIActionSheet
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            actionSheet = UIActionSheet(title: "Hello this is IOS7", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil,otherButtonTitles:"Select photo from library", "Take a picture")
        } else {
            actionSheet = UIActionSheet(title: "Hello this is IOS7", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil,otherButtonTitles:"Select photo from library")
        }
        actionSheet.delegate = self
        actionSheet.showInView(self.view)
    }
    
    // Action sheet delegate for iOS7
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex != 0){
            let imageController = UIImagePickerController()
            imageController.editing = false
            imageController.delegate = self;
            if( buttonIndex == 1){
                imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            } else if(buttonIndex == 2){
                imageController.sourceType = UIImagePickerControllerSourceType.Camera
            }
            self.presentViewController(imageController, animated: true, completion: nil)
        }
    }
}