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
        passwordObserver = NSNotificationCenter.defaultCenter().addObserverForName(passwordChangedNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleChangePassword(notification)})
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
        NSNotificationCenter.defaultCenter().removeObserver(passwordObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    // On focus textField behaviours
    @IBAction func oldPasswordOnFocus(sender: UITextField) {
        if(sender.text == "Old Password"){
            sender.text = ""
            sender.secureTextEntry = true
        }
    }
    
    @IBAction func passwordOnFocus(sender: UITextField) {
        if(sender.text == "New Password"){
            sender.text! = ""
            sender.secureTextEntry = true
        }
    }
    
    @IBAction func confirmPasswordOnFocus(sender: UITextField) {
        if(sender.text == "Confirm Password"){
            sender.text! = ""
            sender.secureTextEntry = true
        }
    }
    
    // Off focus textField behaviours
    @IBAction func oldPasswordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = "Old Password"
            sender.secureTextEntry = false
        }
    }
    
    @IBAction func passwordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = "New Password"
            sender.secureTextEntry = false
        }
    }
    
    @IBAction func confirmPasswordOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = "Confirm Password"
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
    
    @IBAction func changePasswordButtonPressed(sender: UIButton) {
        if(passwordTextField.text == ""){
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Password may not be empty"
            alert.addButtonWithTitle("Dismiss")
            alert.show()
        }
        else if(count(passwordTextField.text) < 4){
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Password must be at least 4 characters long"
            alert.addButtonWithTitle("Dismiss")
            alert.show()
        }
        else if(passwordTextField.text != confirmPasswordTextField.text){
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Password Mismatch"
            alert.addButtonWithTitle("Dismiss")
            alert.show()
        }
        else{
            RestInterface.getInstance().changePassword(oldPasswordTextField.text, new_password: passwordTextField.text)
            changePasswordButton.enabled = false
            changePasswordActivityIndicator.startAnimating()
        }
    }
    
    private func setUpInterface(){
        oldPasswordTextField.text = "Old Password"
        passwordTextField.text = "New Password"
        confirmPasswordTextField.text = "Confirm Password"
        changePasswordButton.enabled = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func handleChangePassword(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "The current password is wrong"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        else if(response?.status == RequestStatus.DEVICE_ERROR || response?.status == RequestStatus.NETWORK_ERROR){
            let alert = UIAlertView()
            alert.title = "No connection"
            alert.message = "Check you network connectivity and try again"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        else{
            let alert = UIAlertView()
            alert.title = "Password changed successfully"
            alert.message = "Top!"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        changePasswordButton.enabled = true
        changePasswordActivityIndicator.stopAnimating()
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
