//
//  NewDonationViewController.swift
//  Bring the Food
//
//  Created by federico badini on 27/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class NewDonationViewController: UIViewController, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var freshFoodButton: UIButton!
    @IBOutlet weak var cookedFoodButton: UIButton!
    @IBOutlet weak var driedFoodButton: UIButton!
    @IBOutlet weak var frozenFoodButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var kgButton: UIButton!
    @IBOutlet weak var ltButton: UIButton!
    @IBOutlet weak var portionsButton: UIButton!
    @IBOutlet weak var expirationTextField: UITextField!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var textFieldsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodTypeView: UIView!
    @IBOutlet weak var submitDonationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Keyboard height
    private var kbHeight: CGFloat!
    
    // Observers
    private weak var newDonationObserver: NSObjectProtocol?
    private weak var keyboardWillShowObserver:NSObjectProtocol?
    private weak var keyboardWillHideObserver:NSObjectProtocol?
    private var tapRecognizer:UITapGestureRecognizer!
    
    // Private variables
    private var productType: ProductType?
    private var parcelUnit: ParcelUnit?
    private var lastDateSelected: NSDate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        newDonationObserver = NSNotificationCenter.defaultCenter().addObserverForName(donationCreatedNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleNewDonation(notification)})
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
        NSNotificationCenter.defaultCenter().removeObserver(newDonationObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver!)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func freshFoodButtonPressed(sender: UIButton) {
        productType = ProductType.FRESH
        updateFoodType()
    }
    
    @IBAction func cookedFoodButtonPressed(sender: UIButton) {
        productType = ProductType.COOKED
        updateFoodType()
    }
    
    @IBAction func driedFoodButtonPressed(sender: UIButton) {
        productType = ProductType.DRIED
        updateFoodType()
    }
    
    @IBAction func frozenFoodButtonPressed(sender: UIButton) {
        productType = ProductType.FROZEN
        updateFoodType()
    }
    
    @IBAction func kgButtonPressed(sender: UIButton) {
        parcelUnit = ParcelUnit.KILOGRAMS
        updateParcelUnit()
    }
    
    @IBAction func ltButtonPressed(sender: UIButton) {
        parcelUnit = ParcelUnit.LITERS
        updateParcelUnit()
    }
    
    @IBAction func portionsButtonPressed(sender: UIButton) {
        parcelUnit = ParcelUnit.PORTIONS
        updateParcelUnit()
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

    @IBAction func expirationOnFocus(sender: UITextField) {
        if(sender.text == NSLocalizedString("EXPIRATION",comment:"Expiration")){
            sender.text = ""
        }
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.minimumDate = NSDate()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
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
    
    @IBAction func expirationOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            sender.text = NSLocalizedString("EXPIRATION",comment:"Expiration")
        }
    }
    
    // Enables submit donation button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (descriptionTextField.text != "" && descriptionTextField.text != NSLocalizedString("DESCRIPTION",comment:"Description")
            && amountTextField.text != "" && amountTextField.text != NSLocalizedString("AMOUNT",comment:"Amount")
            && expirationTextField.text != "" && expirationTextField.text != NSLocalizedString("EXPIRATION",comment:"Expiration")){
                submitDonationButton.enabled = true
        }
        else{
            submitDonationButton.enabled = false
        }
    }
    
    @IBAction func submitDonationButtonPressed(sender: UIButton) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(lastDateSelected!)
        let filteredDescription = descriptionTextField.text.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let donation = NewDonation(filteredDescription, parcelSize: (amountTextField.text as NSString).floatValue, parcelUnit: parcelUnit!, productDate: Date(dateString: dateString), productType: productType!)
        RestInterface.getInstance().createDonation(donation)
        submitDonationButton.enabled = false
        activityIndicator.startAnimating()
    }
    
    func setUpInterface(){
        descriptionTextField.text = NSLocalizedString("DESCRIPTION",comment:"Description")
        amountTextField.text = NSLocalizedString("AMOUNT",comment:"Amount")
        expirationTextField.text = NSLocalizedString("EXPIRATION",comment:"Expiration")
        productType = ProductType.FRESH
        freshFoodButton.setImage(UIImage(named: "fresh"), forState: UIControlState.Selected)
        freshFoodButton.highlighted = false
        cookedFoodButton.setImage(UIImage(named: "cooked"), forState: UIControlState.Selected)
        cookedFoodButton.highlighted = false
        driedFoodButton.setImage(UIImage(named: "dried"), forState: UIControlState.Selected)
        driedFoodButton.highlighted = false
        frozenFoodButton.setImage(UIImage(named: "frozen"), forState: UIControlState.Selected)
        frozenFoodButton.highlighted = false
        updateFoodType()
        parcelUnit = ParcelUnit.KILOGRAMS
        updateParcelUnit()
    }
    
    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func updateFoodType(){
        if(productType == ProductType.FRESH){
            freshFoodButton.selected = true
        }
        else{
            freshFoodButton.selected = false
        }
        if(productType == ProductType.COOKED){
            cookedFoodButton.selected = true
            expirationTextField.enabled = false
            let currentDate = NSDate()
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            expirationTextField.text = dateFormatter.stringFromDate(currentDate)
            lastDateSelected = currentDate
        }
        else{
            cookedFoodButton.selected = false
            expirationTextField.enabled = true
            expirationTextField.text = NSLocalizedString("EXPIRATION",comment:"Expiration")
        }
        if(productType == ProductType.DRIED){
            driedFoodButton.selected = true
        }
        else{
            driedFoodButton.selected = false
        }
        if(productType == ProductType.FROZEN){
            frozenFoodButton.selected = true
        }
        else{
            frozenFoodButton.selected = false
        }
    }
    
    func updateParcelUnit(){
        if(parcelUnit == ParcelUnit.KILOGRAMS){
            kgButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            kgButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        if(parcelUnit == ParcelUnit.LITERS){
            ltButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            ltButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        if(parcelUnit == ParcelUnit.PORTIONS){
            portionsButton.setTitleColor(UIMainColor, forState: .Normal)
        }
        else{
            portionsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    func handleNewDonation(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("SUBMISSION_FAILED",comment:"Submission failed")
            alert.message = NSLocalizedString("SUBMISSION_FAILED_MESSAGE",comment:"Submission failed message")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        else if(response?.status == RequestStatus.DEVICE_ERROR || response?.status == RequestStatus.NETWORK_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            alert.message = NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
            alert.addButtonWithTitle(NSLocalizedString("DISMISS",comment:"Dismiss"))
            alert.delegate = self
            alert.show()
        }
        activityIndicator.stopAnimating()
        submitDonationButton.enabled = true
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
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        expirationTextField.text = dateFormatter.stringFromDate(sender.date)
        lastDateSelected = sender.date
        reactToFieldsInteraction(expirationTextField)
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}