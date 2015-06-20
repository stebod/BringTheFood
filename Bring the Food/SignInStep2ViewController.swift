//
//  SignInStep2ViewController.swift
//  Bring the Food
//
//  Created by federico badini on 08/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class SignInStep2ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate {
    
    // Outlets
    @IBOutlet weak var nameImageView: UIImageView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var avatarViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsView: UIView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    private var textFieldBorderColor = UIColor(red: 0xe9/255, green: 0xe9/255, blue: 0xe9/255, alpha: 1)
    private var buttonBorderColor = UIColor(red: 0xf8/255, green: 0xd0/255, blue: 0x8f/255, alpha: 1)
    
    // Keyboard height
    private var kbHeight: CGFloat!
    
    // Variables populated from prepareForSegue
    var email = String()
    var password = String()
    
    // Observers
    private weak var registrationObserver:NSObjectProtocol!
    private weak var keyboardWillShowObserver:NSObjectProtocol!
    private weak var keyboardWillHideObserver:NSObjectProtocol!
    private var tapRecognizer:UITapGestureRecognizer!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register as notification center observer
        registrationObserver = NSNotificationCenter.defaultCenter().addObserverForName(registrationResponseNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.registrationHandler(notification)})
        keyboardWillShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillShow(notification)})
        keyboardWillHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillHide(notification)})
        // Set tap recognizer on the view
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister as notification center observer
        NSNotificationCenter.defaultCenter().removeObserver(registrationObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func changeAvatarPressed(sender: AnyObject) {
        if( controllerAvailable()){
            displayIOS8ActionSheet()
        } else {
            displayIOS7ActionSheet()
        }
    }
    
    // On focus textField behaviours
    @IBAction func nameOnFocus(sender: UITextField) {
        nameImageView.hidden = true
        if(sender.text == "Name"){
            sender.text = ""
        }
    }
    
    @IBAction func phoneOnFocus(sender: UITextField) {
        phoneImageView.hidden = true
        if(sender.text == "Phone"){
            sender.text! = ""
        }
    }
    
    @IBAction func addressOnFocus(sender: UITextField) {
        addressImageView.hidden = true
        if(sender.text == "Address"){
            sender.text! = ""
        }
    }
    
    // Off focus textField behaviours
    @IBAction func nameOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            nameImageView.hidden = false
            sender.text = "Name"
        }
    }
    
    @IBAction func phoneOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            phoneImageView.hidden = false
            sender.text = "Phone"
        }
    }
    
    @IBAction func addressOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            addressImageView.hidden = false
            sender.text = "Address"
        }
    }
    
    // Enables register button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (nameTextField.text != "" && nameTextField != "Name"
            && phoneTextField.text != "" && phoneTextField.text != "Phone"
            && addressTextField.text != "" && addressTextField.text != "Address"){
                registerButton.enabled = true
        }
        else{
            registerButton.enabled = false
        }
    }
    
    // Register button pressed
    @IBAction func registerButtonPressed(sender: UIButton) {
        //TODO: IMPLEMENT REGISTRATION
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Abort button pressed
    @IBAction func abortRegistration(sender: UIButton) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User interface settings
    private func setUpInterface() -> Void {
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = textFieldBorderColor.CGColor
        nameTextField.layer.cornerRadius = 3
        nameTextField.textColor = UIMainColor
        nameTextField.text = "Name"
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = textFieldBorderColor.CGColor
        phoneTextField.layer.cornerRadius = 3
        phoneTextField.textColor = UIMainColor
        phoneTextField.text = "Phone"
        addressTextField.layer.borderWidth = 1
        addressTextField.layer.borderColor = textFieldBorderColor.CGColor
        addressTextField.layer.cornerRadius = 3
        addressTextField.textColor = UIMainColor
        addressTextField.text = "Address"
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = buttonBorderColor.CGColor
        registerButton.layer.cornerRadius = 3
        registerButton.enabled = false
    }
    
    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Handle registration
    private func registrationHandler(notification: NSNotification){
        
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
    
    // Called when keyboard appears on screen
    private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    // Called when keyboard disappears from screen
    private func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    // Perform animations when keyboard appears
    private func animateTextField(up: Bool) {
        if(up){
            if(self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 < kbHeight + 10){
                UIView.animateWithDuration(0.3, animations: {
                    self.textFieldsTopConstraint.constant -= self.kbHeight + 10 - (self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2)
                    self.textFieldsBottomConstraint.constant += self.kbHeight + 10 - (self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 )
                    self.textFieldsCenterYConstraint.constant += self.kbHeight + 10 - (self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 )
                    self.avatarViewTopConstraint.constant -= 300
                    self.avatarViewBottomConstraint.constant += 300
                    self.view.layoutIfNeeded()
                })
            }
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                self.textFieldsTopConstraint.constant = 0
                self.textFieldsBottomConstraint.constant = 0
                self.textFieldsCenterYConstraint.constant = -14
                self.avatarViewTopConstraint.constant = 0
                self.avatarViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
}


