//
//  NewDonationViewController.swift
//  Bring the Food
//
//  Created by federico badini on 27/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit
class ModifyDonationViewController: UIViewController, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var freshFoodImageView: UIImageView!
    @IBOutlet weak var cookedFoodImageView: UIImageView!
    @IBOutlet weak var driedFoodImageView: UIImageView!
    @IBOutlet weak var frozenFoodImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var kgLabel: UILabel!
    @IBOutlet weak var ltLabel: UILabel!
    @IBOutlet weak var portionsLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var textFieldsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeView: UIView!
    @IBOutlet weak var updateDonationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Keyboard height
    private var kbHeight: CGFloat!
    
    // Variables populated from prepareForSegue
    var donation: MyDonation?
    
    // Observers
    private weak var updateDonationObserver: NSObjectProtocol?
    private weak var keyboardWillShowObserver:NSObjectProtocol?
    private weak var keyboardWillHideObserver:NSObjectProtocol?
    private var tapRecognizer:UITapGestureRecognizer!
    
    // Private variables
    private var productType: ProductType?
    private var parcelUnit: ParcelUnit?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        updateDonationObserver = NSNotificationCenter.defaultCenter().addObserverForName(donationUpdatedNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleUpdateDonation(notification)})
        keyboardWillShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillShow(notification)})
        keyboardWillHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.keyboardWillHide(notification)})
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(updateDonationObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver!)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // On focus textField behaviours
    @IBAction func descriptionOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("DESCRIPTION",comment:"Description")){
            sender.text = ""
        }
    }
    
    @IBAction func amountOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("AMOUNT",comment:"Amount")){
            sender.text! = ""
        }
    }
    
    // Off focus textField behaviours
    @IBAction func descriptionOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("DESCRIPTION",comment:"Description")
        }
    }
    
    @IBAction func amountOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("AMOUNT",comment:"Amount")
        }
    }
    
    // Enables submit donation button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (descriptionTextField.text != "" && descriptionTextField.text != NSLocalizedString("DESCRIPTION",comment:"Description")
            && amountTextField.text != "" && amountTextField.text != NSLocalizedString("AMOUNT",comment:"Amount")){
                updateDonationButton.enabled = true
        }
        else{
            updateDonationButton.enabled = false
        }
    }
    
    @IBAction func submitDonationButtonPressed(sender: UIButton) {
        if((amountTextField.text as NSString).floatValue < Float(Int.max)){
            donation?.modify(descriptionTextField.text, newParcelSize: (amountTextField.text as NSString).floatValue)
            updateDonationButton.enabled = false
            activityIndicator.startAnimating()
        }
        else{
            let alert = UIAlertView()
            alert.title = NSLocalizedString("EXCESSIVE_AMOUNT",comment:"Too many kg")
            alert.message = NSLocalizedString("EXCESSIVE_AMOUNT_MESSAGE",comment:"Too many kg message")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.show()
        }
    }
    
    func setUpInterface(){
        freshFoodImageView.image = UIImage(named: NSLocalizedString("FRESH_GREY",comment:"Fresh grey"))
        cookedFoodImageView.image = UIImage(named: NSLocalizedString("COOKED_GREY",comment:"Cooked grey"))
        driedFoodImageView.image = UIImage(named: NSLocalizedString("DRIED_GREY",comment:"Dried grey"))
        frozenFoodImageView.image = UIImage(named: NSLocalizedString("FROZEN_GREY",comment:"Frozen grey"))
        descriptionTextField.text = donation!.getDescription()
        amountTextField.text = String(stringInterpolationSegment: Int(donation!.getParcelSize()))
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        expirationLabel.text = dateFormatter.stringFromDate(donation!.getProductDate().getDate())
        productType = donation!.getProductType()
        updateFoodType()
        parcelUnit = donation!.getParcelUnit()
        updateParcelUnit()
    }
    
    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func updateFoodType(){
        freshFoodImageView.hidden = true
        cookedFoodImageView.hidden = true
        driedFoodImageView.hidden = true
        frozenFoodImageView.hidden = true
        let donationType = donation!.getProductType()
        if(donationType == ProductType.FRESH){
            freshFoodImageView.hidden = false
        }
        else if(donationType == ProductType.COOKED){
            cookedFoodImageView.hidden = false
        }
        else if(donationType == ProductType.DRIED){
            driedFoodImageView.hidden = false
        }
        else{
            frozenFoodImageView.hidden = false
        }
    }
    
    func updateParcelUnit(){
        kgLabel.hidden = true
        ltLabel.hidden = true
        portionsLabel.hidden = true
        let donationParcelUnit = donation!.getParcelUnit()
        if(donationParcelUnit == ParcelUnit.KILOGRAMS){
            kgLabel.hidden = false
        }
        else if(donationParcelUnit == ParcelUnit.LITERS){
            ltLabel.hidden = false
        }
        else{
            portionsLabel.hidden = false
        }
    }
    
    func handleUpdateDonation(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("DONATION_UPDATE_FAILED",comment:"Donation update failed")
            alert.message = NSLocalizedString("DONATION_UPDATE_FAILED_MESSAGE",comment:"Donation update failed message")
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
        activityIndicator.stopAnimating()
        updateDonationButton.enabled = true
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
            if(self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 < kbHeight + 20){
                UIView.animateWithDuration(0.3, animations: {
                    let movement = self.kbHeight + 20 - (self.view.frame.height - self.textFieldsView.center.y - self.textFieldsView.frame.height/2 )
                    self.textFieldsTopConstraint.constant = 0 - movement
                    if(self.foodTypeView.center.y < 145){
                        self.foodTypeTopConstraint.constant -= 300
                        self.foodTypeBottomConstraint.constant += 300
                    }
                    self.view.layoutIfNeeded()
                })
            }
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                self.textFieldsTopConstraint.constant = 0
                self.textFieldsCenterYConstraint.constant = -16
                self.textFieldsBottomConstraint.constant = 0
                self.foodTypeBottomConstraint.constant = 0
                self.foodTypeTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}