//
//  NotificationSettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 23/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var newDonationSwitch: UISwitch!
    @IBOutlet weak var newBookingSwitch: UISwitch!
    @IBOutlet weak var collectedDonationSwitch: UISwitch!
    @IBOutlet weak var dropBookingSwitch: UISwitch!
    @IBOutlet weak var fivekmButton: UIButton!
    @IBOutlet weak var tenkmButton: UIButton!
    @IBOutlet weak var twentyfivekmButton: UIButton!
    @IBOutlet weak var fiftykmButton: UIButton!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)

    // Observers
    private weak var notificationsObserver:NSObjectProtocol?
    
    // Private variables
    private var currentDistance: Int?
    private enum Distances: Int {
        case five = 5
        case ten = 10
        case twentyfive = 25
        case fifty = 50
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        notificationsObserver = NSNotificationCenter.defaultCenter().addObserverForName(getSettingsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleResponse(notification)})
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
        
    }
    
    func handleResponse(notification: NSNotification){
        println("received")
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            println("success")
            let mySettings = Model.getInstance().getMySettings()
            currentDistance = mySettings?.getMaxDistance()
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
    
}