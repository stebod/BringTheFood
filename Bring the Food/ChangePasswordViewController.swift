//
//  ChangePasswordViewController.swift
//  Bring the Food
//
//  Created by federico badini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UIAlertViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var changePasswordActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var credentialsTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var credentialsBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLinearView: UIView!
    @IBOutlet weak var credentialsImageView: UIImageView!
    
    // Keyboard height
    private var kbHeight: CGFloat!
    
    // Observers
    private weak var passwordObserver: NSObjectProtocol!
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
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    // On focus textField behaviours
    @IBAction func oldPasswordOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("OLD_PASSWORD",comment:"Old password")){
            sender.text = ""
            sender.secureTextEntry = true
        }
    }
    
    @IBAction func passwordOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("NEW_PASSWORD",comment:"New password")){
            sender.text! = ""
            sender.secureTextEntry = true
        }
    }
    
    @IBAction func confirmPasswordOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("CONFIRM_PASSWORD",comment:"Confirm password")){
            sender.text! = ""
            sender.secureTextEntry = true
        }
    }
    
    // Off focus textField behaviours
    @IBAction func oldPasswordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("OLD_PASSWORD",comment:"Old password")
            sender.secureTextEntry = false
        }
    }
    
    @IBAction func passwordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("NEW_PASSWORD",comment:"New password")
            sender.secureTextEntry = false
        }
    }
    
    @IBAction func confirmPasswordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("CONFIRM_PASSWORD",comment:"Confirm password")
            sender.secureTextEntry = false
        }
    }
    
    // Enables next button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (oldPasswordTextField.text != "" && passwordTextField.text != ""
            && (passwordTextField.secureTextEntry == true)
            && confirmPasswordTextField.text != "" && (confirmPasswordTextField.secureTextEntry == true)){
                changePasswordButton.enabled = true
        }
        else{
            changePasswordButton.enabled = false
        }
    }
    
    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changePasswordButtonPressed(sender: UIButton) {
        if(count(passwordTextField.text) < 4){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("ERROR",comment:"Error")
            alert.message = NSLocalizedString("INVALID_PASSWORD",comment:"Invalid password")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        else if(passwordTextField.text != confirmPasswordTextField.text){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("ERROR",comment:"Error")
            alert.message = NSLocalizedString("PASSWORD_MISMATCH",comment:"Password mismatch")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        else{
            if(passwordObserver != nil){
                passwordObserver = NSNotificationCenter.defaultCenter().addObserverForName(passwordChangedNotificationKey,
                    object: ModelUpdater.getInstance(),
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: {(notification:NSNotification!) in self.handleChangePassword(notification)})
            }
            RestInterface.getInstance().changePassword(oldPasswordTextField.text, new_password: passwordTextField.text)
            changePasswordButton.enabled = false
            changePasswordActivityIndicator.startAnimating()
        }
    }
    
    private func setUpInterface(){
        oldPasswordTextField.text = NSLocalizedString("OLD_PASSWORD",comment:"Old password")
        passwordTextField.text = NSLocalizedString("NEW_PASSWORD",comment:"New password")
        confirmPasswordTextField.text = NSLocalizedString("CONFIRM_PASSWORD",comment:"Confirm password")
        changePasswordButton.enabled = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func handleChangePassword(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("OLD_PASSWORD_WRONG",comment:"Old password wrong")
            alert.message = NSLocalizedString("OLD_PASSWORD_WRONG_MESSAGE",comment:"Old password wrong message")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        else if(response?.status == RequestStatus.DEVICE_ERROR || response?.status == RequestStatus.NETWORK_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
        else{
            let alert = UIAlertView()
            alert.title = NSLocalizedString("SUCCESS",comment:"Success")
            alert.message = NSLocalizedString("PASSWORD_CHANGED_SUCCESSFULLY",comment:"Password changed successfully")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        changePasswordButton.enabled = true
        changePasswordActivityIndicator.stopAnimating()
        NSNotificationCenter.defaultCenter().removeObserver(passwordObserver)
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
            if(self.view.frame.height - self.bottomLinearView.center.y < kbHeight + 20){
                UIView.animateWithDuration(0.3, animations: {
                    let movement = self.kbHeight + 20 - (self.view.frame.height - self.bottomLinearView.center.y)
                    self.credentialsBottomLayoutConstraint.constant -= movement
                    if(self.view.bounds.height < 481){
                        self.credentialsTopLayoutConstraint.constant -= 300
                        self.credentialsBottomLayoutConstraint.constant += 300
                    }
                    self.view.layoutIfNeeded()
                })
            }
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
                if(iOS7){
                    self.credentialsBottomLayoutConstraint.constant = 33
                    self.credentialsTopLayoutConstraint.constant = 36
                }
                else{
                    self.credentialsBottomLayoutConstraint.constant = 33
                    self.credentialsTopLayoutConstraint.constant = 36
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
