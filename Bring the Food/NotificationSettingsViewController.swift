//
//  NotificationSettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 23/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var newDonationSwitch: UISwitch!
    @IBOutlet weak var newBookingSwitch: UISwitch!
    @IBOutlet weak var collectedDonationSwitch: UISwitch!
    @IBOutlet weak var dropBookingSwitch: UISwitch!
    @IBOutlet weak var fivekmButton: UIButton!
    @IBOutlet weak var tenkmButton: UIButton!
    @IBOutlet weak var twentyfivekmButton: UIButton!
    @IBOutlet weak var fiftykmButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var applyChangesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var applyChangesButton: UIButton!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)

    // Observers
    private weak var notificationsObserver:NSObjectProtocol?
    private weak var changeNotificationsObserver:NSObjectProtocol?
    
    // Private variables
    private var deltaHeight: CGFloat?
    private var currentDistance: Int?
    private enum Distances: Int {
        case five = 5
        case ten = 10
        case twentyfive = 25
        case fifty = 50
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        notificationsObserver = NSNotificationCenter.defaultCenter().addObserverForName(getSettingsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleReceivedSettings(notification)})
        Model.getInstance().downloadMySettings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister notification center observer
        NSNotificationCenter.defaultCenter().removeObserver(notificationsObserver!)
        super.viewWillDisappear(animated)
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func fivekmButtonPressed(sender: UIButton) {
        currentDistance = Distances.five.rawValue
        updateDistanceButtonSet()
    }

    @IBAction func tenkmButtonPressed(sender: UIButton) {
        currentDistance = Distances.ten.rawValue
        updateDistanceButtonSet()
    }
    
    @IBAction func twentyfivekmButtonPressed(sender: UIButton) {
        currentDistance = Distances.twentyfive.rawValue
        updateDistanceButtonSet()
    }

    @IBAction func fiftykmButtonPressed(sender: UIButton) {
        currentDistance = Distances.fifty.rawValue
        updateDistanceButtonSet()
    }
    
    @IBAction func applyButtonPressed(sender: UIButton) {
        if(changeNotificationsObserver == nil){
            changeNotificationsObserver = NSNotificationCenter.defaultCenter().addObserverForName(settingsUpdatedNotificationKey,
                object: ModelUpdater.getInstance(),
                queue: NSOperationQueue.mainQueue(),
                usingBlock: {(notification:NSNotification!) in self.handleChangedSettings(notification)})
        }
        RestInterface.getInstance().updateSettings(newDonationSwitch.on, bookedEmail: newBookingSwitch.on, retractedEmail: dropBookingSwitch.on, collectedEmail: collectedDonationSwitch.on, maxDistance: currentDistance)
        applyChangesButton.enabled = false
        applyChangesActivityIndicator.startAnimating()
    }
    
    func handleReceivedSettings(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let mySettings = Model.getInstance().getMySettings()
            currentDistance = correctDistance(mySettings!.getMaxDistance())
            updateDistanceButtonSet()
            if(mySettings!.getPublishedEmail() == true){
                newDonationSwitch.setOn(true, animated: true)
            }
            else{
                newDonationSwitch.setOn(false, animated: true)
            }
            if(mySettings!.getBookedEmail() == true){
                newBookingSwitch.setOn(true, animated: true)
            }
            else{
                newBookingSwitch.setOn(false, animated: true)
            }
            if(mySettings!.getCollectedEmail() == true){
                collectedDonationSwitch.setOn(true, animated: true)
            }
            else{
                collectedDonationSwitch.setOn(false, animated: true)
            }
            if(mySettings!.getRetractedEmail() == true){
                dropBookingSwitch.setOn(true, animated: true)
            }
            else{
                dropBookingSwitch.setOn(false, animated: true)
            }
        }
    }
    
    func handleChangedSettings(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NOTIFICATION_UPDATE_ERROR",comment:"Notification update error")
            alert.message = NSLocalizedString("NOTIFICATION_UPDATE_ERROR_MESSAGE",comment:"Notification update error message")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        else if (response?.status == RequestStatus.DEVICE_ERROR || response?.status == RequestStatus.NETWORK_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        else if (response?.status == RequestStatus.SUCCESS){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("SUCCESS",comment:"Success")
            alert.message = NSLocalizedString("NOTIFICATION_UPDATE_ACCOMPLISHED",comment:"Notification update accomplished")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        NSNotificationCenter.defaultCenter().removeObserver(changeNotificationsObserver!)
        applyChangesActivityIndicator.stopAnimating()
        applyChangesButton.enabled = true
    }
    
    private func updateDistanceButtonSet(){
        if(currentDistance == Distances.five.rawValue){
            fivekmButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            fivekmButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        if(currentDistance == Distances.ten.rawValue){
            tenkmButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            tenkmButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        if(currentDistance == Distances.twentyfive.rawValue){
            twentyfivekmButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            twentyfivekmButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        if(currentDistance == Distances.fifty.rawValue){
            fiftykmButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            fiftykmButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    private func correctDistance(inputDistance: Int) -> Int{
        if(inputDistance <= Distances.five.rawValue){
            return Distances.five.rawValue
        }
        if(inputDistance <= Distances.ten.rawValue){
            return Distances.ten.rawValue
        }
        if(inputDistance <= Distances.twentyfive.rawValue){
            return Distances.twentyfive.rawValue
        }
        return Distances.fifty.rawValue
    }
    
    private func setUpInterface(){
        let contentViewVisibleHeight = UIScreen.mainScreen().bounds.height - headerView.bounds.height - 49
        deltaHeight = contentView.bounds.height - contentViewVisibleHeight
        if(deltaHeight < 0){
            buttonTopConstraint.constant -= deltaHeight!
            self.view.layoutIfNeeded()
        }
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}