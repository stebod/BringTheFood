//
//  ChangeSettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class ChangeSettingsViewController: UIViewController,UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AddressCommunicator {

    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addressToButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addressUnderlineView: UIView!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeSettingsButton: UIButton!
    @IBOutlet weak var changeSettingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTopLayoutConstraint: NSLayoutConstraint!
    
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
    private weak var keyboardWillShowObserver:NSObjectProtocol!
    private weak var keyboardWillHideObserver:NSObjectProtocol!
    private var tapRecognizer:UITapGestureRecognizer!
    private weak var mailObserver:NSObjectProtocol?
    
    // Keyboard height
    private var kbHeight: CGFloat!
    
    // Location autocompleter
    private var locationAutocompleter: LocationAutocompleter?
    
    // Private variables
    private var deltaHeight: CGFloat?
    private var locationAutocompleterHeightDelta: CGFloat?
    private var isExpandedForKeyboard: Bool?
    private var isExpandedForTableView: Bool?
    private var openKeyboardMovement: CGFloat?
    private var openTableViewMovement: CGFloat?
    private var contentViewVisibleHeight: CGFloat?

    // Custom user avatar
    private var customAvatar: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated: Bool) {
        locationAutocompleter = LocationAutocompleter(delegate: self)
        // Set tap recognizer on the view
        mailObserver = NSNotificationCenter.defaultCenter().addObserverForName(mailAvailabilityResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.emailAvailabilityHandler(notification)})
        changeSettingsObserver = NSNotificationCenter.defaultCenter().addObserverForName(updateUserNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleChangeSettings(notification)})
        keyboardWillShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillShow(notification)})
        keyboardWillHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillHide(notification)})
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapOnView:")
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister as notification center observer
        NSNotificationCenter.defaultCenter().removeObserver(mailObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(changeSettingsObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changeAvatarPressed(sender: AnyObject) {
        if( controllerAvailable()){
            displayIOS8ActionSheet()
        } else {
            displayIOS7ActionSheet()
        }
    }
    
    // On focus textField behaviours
    @IBAction func emailOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("EMAIL",comment:"Email")){
            sender.text = ""
        }
    }
    
    @IBAction func nameOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("NAME",comment:"Name")){
            sender.text = ""
        }
    }
    
    @IBAction func phoneOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("PHONE",comment:"Phone")){
            sender.text! = ""
        }
    }
    
    @IBAction func addressOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("ADDRESS",comment:"Address")){
            sender.text! = ""
        }
        if(addressTextField.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
        }
    }
    
    // Off focus textField behaviours
    @IBAction func emailOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("EMAIL",comment:"Email")
        }
    }
    
    @IBAction func nameOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("NAME",comment:"Name")
        }
    }
    
    @IBAction func phoneOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("PHONE",comment:"Phone")
        }
    }
    
    @IBAction func addressOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("ADDRESS",comment:"Address")
        }
        addressTableView.hidden = true
        if(isExpandedForTableView == true){
            addressTopLayoutConstraint.constant -= 5
            tableViewBottomLayoutConstraint.constant -= locationAutocompleterHeightDelta!
            addressToButtonLayoutConstraint.constant -= openTableViewMovement!
            self.view.layoutIfNeeded()
            isExpandedForTableView = false
        }
    }

    // Enables register button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        checkIfEnableButton()
    }
    
    private func checkIfEnableButton(){
        if (nameTextField.text != "" && nameTextField != NSLocalizedString("NAME",comment:"Name")
            && phoneTextField.text != "" && phoneTextField.text != NSLocalizedString("PHONE",comment:"Phone")
            && emailTextField.text != "" && emailTextField.text != NSLocalizedString("EMAIL",comment:"Email")
            && addressTextField.text != "" && addressTextField.text != NSLocalizedString("ADDRESS",comment:"Address")){
                if(emailTextField.text != email || phoneTextField.text != phone
                    || nameTextField.text != name || addressTextField.text != address || customAvatar != nil){
                        changeSettingsButton.enabled = true
                }
        }
        else{
            changeSettingsButton.enabled = false
        }
    }
    
    @IBAction func addressChanged(sender: UITextField) {
        if(sender.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
        }
    }

    
    @IBAction func applyChangesButtonPressed(sender: UIButton) {
        if(!isValidEmail(emailTextField.text)){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("ERROR",comment:"Error")
            alert.message = NSLocalizedString("INVALID_EMAIL",comment:"Invalid email")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        else{
            if(emailTextField.text != email){
                RestInterface.getInstance().getEmailAvailability(emailTextField.text)
            }
            else{
                if(addressTextField.text != address){
                    RestInterface.getInstance().updateUser(nameTextField.text, email: emailTextField.text, phoneNumber: phoneTextField.text, avatar: customAvatar == nil ? nil : customAvatar, addressLabel: addressTextField.text)
                }
                else{
                    RestInterface.getInstance().updateUser(nameTextField.text, email: emailTextField.text, phoneNumber: phoneTextField.text, avatar: customAvatar == nil ? nil : customAvatar, addressLabel: nil)
                }
            }
            changeSettingsButton.enabled = false
            changeSettingsActivityIndicator.startAnimating()
        }
    }
    
    // Handle email availability
    private func emailAvailabilityHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response!.status == RequestStatus.SUCCESS){
            if(addressTextField.text != address){
                RestInterface.getInstance().updateUser(nameTextField.text, email: emailTextField.text, phoneNumber: phoneTextField.text, avatar: customAvatar == nil ? nil : customAvatar, addressLabel: addressTextField.text)
            }
            else{
                RestInterface.getInstance().updateUser(nameTextField.text, email: emailTextField.text, phoneNumber: phoneTextField.text, avatar: customAvatar == nil ? nil : customAvatar, addressLabel: nil)
            }
        }
        else {
            if (response!.status == RequestStatus.DATA_ERROR){
                let alert = UIAlertView()
                alert.title = NSLocalizedString("EMAIL_NOT_AVAILABLE",comment:"Email not available")
                alert.message = NSLocalizedString("EMAIL_NOT_AVAILABLE_MESSAGE",comment:"Email not available message")
                alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
                alert.show()
            } else{
                let alert = UIAlertView()
                alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
                alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
                alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
                alert.show()
            }
            changeSettingsActivityIndicator.stopAnimating()
            changeSettingsButton.enabled = true
        }
    }
    
    // Regex check for email
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func setUpInterface(){
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
        changeSettingsButton.enabled = false
        contentViewVisibleHeight = UIScreen.mainScreen().bounds.height - headerView.bounds.height - 49
        deltaHeight = contentView.bounds.height - contentViewVisibleHeight!
        addressToButtonLayoutConstraint.constant -= deltaHeight!
        tableViewBottomLayoutConstraint.constant -= deltaHeight!
        self.view.layoutIfNeeded()
        isExpandedForKeyboard = false
        isExpandedForTableView = false
        openKeyboardMovement = 0
        openTableViewMovement = 0
        kbHeight = 0
    }

    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func communicateAddress(address: String!) {
        addressTextField.text = address
        addressTableView.hidden = true
        self.view.endEditing(true)
    }
    
    func triggerTableUpdate() {
        addressTableView.dataSource = locationAutocompleter
        addressTableView.delegate = locationAutocompleter
        addressTableView.reloadData()
        if(isExpandedForTableView == false){
            openTableViewMovement = addressTextField.center.y
            if(openKeyboardMovement! > 0){
                openTableViewMovement! = openTableViewMovement! - openKeyboardMovement!
            }
            addressTopLayoutConstraint.constant += 5
            addressToButtonLayoutConstraint.constant += openTableViewMovement!
            locationAutocompleterHeightDelta = openTableViewMovement! - (scrollView.bounds.height - kbHeight - addressTableView.bounds.height) + 10
            tableViewBottomLayoutConstraint.constant += locationAutocompleterHeightDelta!
            self.view.layoutIfNeeded()
            scrollView.scrollRectToVisible(CGRectMake(0, 235, scrollView.contentSize.width, scrollView.bounds.height), animated: true)
            isExpandedForTableView = true
        }
        addressTableView.hidden = false
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
        // Use smallest side length as crop square length
        var squareLength = min(image.size.width, image.size.height)
        var clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength)
        customAvatar = image!.imageRotatedByDegrees(false)
        customAvatar = UIImage(CGImage: CGImageCreateWithImageInRect(customAvatar!.CGImage, clippedRect))
        changeAvatarButton.setImage(customAvatar, forState: .Normal)
        checkIfEnableButton()
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
            self.openKeyboardMovement = self.kbHeight + 20 - (self.view.frame.height - self.addressUnderlineView.center.y - self.headerView.bounds.height)
            if(self.view.frame.height - self.addressUnderlineView.center.y - headerView.bounds.height < kbHeight + 20){
                UIView.animateWithDuration(0.3, animations: {
                    self.addressToButtonLayoutConstraint.constant += self.openKeyboardMovement!
                    self.tableViewBottomLayoutConstraint.constant += self.openKeyboardMovement!
                    self.view.layoutIfNeeded()
                    let bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                    self.isExpandedForKeyboard = true
                })
            }
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                if(self.isExpandedForKeyboard == true){
                    self.addressToButtonLayoutConstraint.constant -= self.openKeyboardMovement!
                    self.tableViewBottomLayoutConstraint.constant -= self.openKeyboardMovement!
                    self.view.layoutIfNeeded()
                    self.isExpandedForKeyboard = false
                }
            })
        }
    }
    
    func handleChangeSettings(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response!.status == RequestStatus.SUCCESS){
            self.navigationController!.popViewControllerAnimated(true)
        }
        else if(response!.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("SETTINGS_UPDATE_FAILED",comment:"Settings update failed")
            alert.message = NSLocalizedString("SETTINGS_UPDATE_FAILED_MESSAGE",comment:"Settings update failed message")
            alert.addButtonWithTitle("Dismiss")
            alert.show()
        }
        else{
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        changeSettingsActivityIndicator.stopAnimating()
        changeSettingsButton.enabled = true
    }
}