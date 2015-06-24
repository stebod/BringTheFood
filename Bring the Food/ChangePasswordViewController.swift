//
//  ChangePasswordViewController.swift
//  Bring the Food
//
//  Created by federico badini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController,UIActionSheetDelegate, UIAlertViewDelegate {
    
    // Outlet
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // Observers
    private weak var passwordObserver: NSObjectProtocol!

    
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
        else if(passwordTextField.text != confirmPasswordTextField.text){
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Password Mismatch"
            alert.addButtonWithTitle("Dismiss")
            alert.show()
        }
        else{
            // Register notification center observer
            //passwordObserver = NSNotificationCenter.defaultCenter().addObserverForName(getSettingsResponseNotificationKey,
            //    object: ModelUpdater.getInstance(),
            //    queue: NSOperationQueue.mainQueue(),
            //    usingBlock: {(notification:NSNotification!) in self.handleResponse(notification)})
            //Model.getInstance().downloadMySettings()
        }
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
        //NSNotificationCenter.defaultCenter().removeObserver(bookingObserver)
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}