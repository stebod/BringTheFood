//
//  SignInStep2ViewController.swift
//  Bring the Food
//
//  Created by federico badini on 08/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class SignInStep3ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var backButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameImageView: UIImageView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var takeASelfieLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
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
    var address = String()
    
    // Observers
    private weak var registrationObserver:NSObjectProtocol!
    private weak var locationAutocompleteObserver:NSObjectProtocol!
    private weak var keyboardWillShowObserver:NSObjectProtocol!
    private weak var keyboardWillHideObserver:NSObjectProtocol!
    private var tapRecognizer:UITapGestureRecognizer!
    
    // Custom user avatar
    private var customAvatar: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register as notification center observer
        registrationObserver = NSNotificationCenter.defaultCenter().addObserverForName(createUserNotificationKey,
            object: ModelUpdater.getInstance(),
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
        tapRecognizer.delegate = self
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
        if(sender.text == NSLocalizedString("NAME",comment:"Name")){
            sender.text = ""
        }
    }
    
    @IBAction func phoneOnFocus(sender: UITextField) {
        phoneImageView.hidden = true
        if(sender.text == NSLocalizedString("PHONE",comment:"Phone")){
            sender.text! = ""
        }
    }
    
    // Off focus textField behaviours
    @IBAction func nameOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            nameImageView.hidden = false
            sender.text = NSLocalizedString("NAME",comment:"Name")
        }
    }
    
    @IBAction func phoneOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            phoneImageView.hidden = false
            sender.text = NSLocalizedString("PHONE",comment:"Phone")
        }
    }
    
    // Enables register button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (nameTextField.text != "" && nameTextField != NSLocalizedString("NAME",comment:"Name")
            && phoneTextField.text != "" && phoneTextField.text != NSLocalizedString("PHONE",comment:"Phone")){
                registerButton.enabled = true
        }
        else{
            registerButton.enabled = false
        }
    }
    
    // Register button pressed
    @IBAction func registerButtonPressed(sender: UIButton) {
        RestInterface.getInstance().createUser(nameTextField.text, password: password, email: email, phoneNumber: phoneTextField.text, avatar: customAvatar == nil ? nil : customAvatar, addressLabel: address)
        self.view.endEditing(true)
        activityIndicatorView.startAnimating()
        registerButton.enabled = false
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
        nameTextField.text = NSLocalizedString("NAME",comment:"Name")
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = textFieldBorderColor.CGColor
        phoneTextField.layer.cornerRadius = 3
        phoneTextField.textColor = UIMainColor
        phoneTextField.text = NSLocalizedString("PHONE",comment:"Phone")
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
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response!.status == RequestStatus.SUCCESS){
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
        else if(response!.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("REGISTRATION_FAILED",comment:"Registration failed")
            alert.message = NSLocalizedString("REGISTRATION_FAILED_MESSAGE",comment:"Registration failed message")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        else{
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        activityIndicatorView.stopAnimating()
        registerButton.enabled = true
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
        
        let alert = UIAlertController(title: NSLocalizedString("CHOOSE_AVATAR",comment:"Choose avatar"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: NSLocalizedString("SELECT_FROM_LIBRARY",comment:"Select from library"), style: UIAlertActionStyle.Default) { (alert) -> Void in
            imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imageController, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: NSLocalizedString("TAKE_PICTURE",comment:"Take picture"), style: UIAlertActionStyle.Default) { (alert) -> Void in
                imageController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imageController, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        }
        let cancelButton = UIAlertAction(title: NSLocalizedString("CANCEL",comment:"Cancel"), style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            return
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
        customAvatar = image.fixOrientation()
        // Use smallest side length as crop square length
        var squareLength = min(customAvatar!.size.width, customAvatar!.size.height)
        var clippedRect = CGRectMake((customAvatar!.size.width - squareLength) / 2, (customAvatar!.size.height - squareLength) / 2, squareLength, squareLength)
        customAvatar = UIImage(CGImage: CGImageCreateWithImageInRect(customAvatar!.CGImage, clippedRect))
        changeAvatarButton.setImage(customAvatar, forState: .Normal)
    }
    
    // Action sheet display in iOS7
    private func displayIOS7ActionSheet() -> Void {
        var actionSheet:UIActionSheet
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            actionSheet = UIActionSheet(title: NSLocalizedString("CHOOSE_AVATAR",comment:"Choose avatar"), delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL",comment:"Cancel"), destructiveButtonTitle: nil,otherButtonTitles:NSLocalizedString("SELECT_FROM_LIBRARY",comment:"Select from library"), NSLocalizedString("TAKE_PICTURE",comment:"Take picture"))
        } else {
            actionSheet = UIActionSheet(title: NSLocalizedString("CHOOSE_AVATAR",comment:"Choose avatar"), delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL",comment:"Cancel"), destructiveButtonTitle: nil,otherButtonTitles:NSLocalizedString("SELECT_FROM_LIBRARY",comment:"Select from library"))
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
            if(self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 < kbHeight - 10){
                UIView.animateWithDuration(0.3, animations: {
                    let movement = self.kbHeight - 10 - (self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 )
                    self.textFieldsCenterYConstraint.constant += movement
                    self.textFieldsTopConstraint.constant -= movement
                    if(self.avatarView.center.y - self.changeAvatarButton.frame.height/2 < 60){
                        self.avatarViewTopConstraint.constant -= 300
                        self.avatarViewBottomConstraint.constant += 300
                        self.backButtonTopConstraint.constant -= 300
                    }
                    if(self.avatarView.center.y - self.changeAvatarButton.frame.height/2 < 80){
                        self.takeASelfieLabel.alpha = 0.0
                    }
                    self.view.layoutIfNeeded()
                })
            }
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
                if(iOS7){
                    self.textFieldsTopConstraint.constant = -8
                }
                else{
                    self.textFieldsTopConstraint.constant = 0
                }
                self.textFieldsCenterYConstraint.constant = -32
                self.textFieldsBottomConstraint.constant = 0
                self.avatarViewTopConstraint.constant = 0
                if(iOS7){
                    self.avatarViewBottomConstraint.constant = -8
                }
                else{
                    self.avatarViewBottomConstraint.constant = 0
                }
                self.backButtonTopConstraint.constant = 20
                self.takeASelfieLabel.alpha = 1.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}


