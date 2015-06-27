//
//  SignInStep2ViewController.swift
//  Bring the Food
//
//  Created by federico badini on 08/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class SignInStep2ViewController: UIViewController, UIGestureRecognizerDelegate, AddressCommunicator {
    
    // Outlets
    @IBOutlet weak var backButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var mapLogoImageView: UIImageView!
    @IBOutlet weak var mapLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapLogoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var autocompleteTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
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
    private weak var locationAutocompleteObserver:NSObjectProtocol!
    private weak var keyboardWillShowObserver:NSObjectProtocol!
    private weak var keyboardWillHideObserver:NSObjectProtocol!
    private var tapRecognizer:UITapGestureRecognizer!
    
    // Location autocompleter
    private var locationAutocompleter: LocationAutocompleter!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
        locationAutocompleter = LocationAutocompleter(delegate: self)
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register as notification center observer
        locationAutocompleteObserver = NSNotificationCenter.defaultCenter().addObserverForName(locationAutocompletedNotificationKey,
            object: locationAutocompleter,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.locationAutocompleterHandler(notification)})
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
        NSNotificationCenter.defaultCenter().removeObserver(locationAutocompleteObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillShowObserver)
        NSNotificationCenter.defaultCenter().removeObserver(keyboardWillHideObserver)
        self.view.removeGestureRecognizer(tapRecognizer)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToSignUpStep3") {
            var destViewController : SignInStep3ViewController = segue.destinationViewController as! SignInStep3ViewController
            destViewController.email = email
            destViewController.password = password
            destViewController.address = addressTextField.text
        }
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // On focus textField behaviours
    @IBAction func addressOnFocus(sender: UITextField) {
        addressImageView.hidden = true
        nextButton.hidden = true
        if(sender.text == "Address"){
            sender.text! = ""
        }
        if(addressTextField.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
        }
        autocompleteTableView.hidden = false
    }
    
    // Off focus textField behaviours
    @IBAction func addressOffFocus(sender: UITextField) {
        if (sender.text.isEmpty){
            addressImageView.hidden = false
            sender.text = "Address"
        }
        nextButton.hidden = false
        autocompleteTableView.hidden = true
    }
    
    // Enables next button
    @IBAction func reactToFieldsInteraction(sender: UITextField) {
        if (addressTextField.text != "" && addressTextField.text != "Address"){
                nextButton.enabled = true
        }
        else{
            nextButton.enabled = false
        }
    }
    
    @IBAction func addressChanged(sender: UITextField) {
        if(sender.text != ""){
            locationAutocompleter?.retreiveCompleteAddress(addressTextField.text)
        }
    }
    
    // Abort button pressed
    @IBAction func abortRegistration(sender: UIButton) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User interface settings
    private func setUpInterface() -> Void {
        addressTextField.layer.borderWidth = 1
        addressTextField.layer.borderColor = textFieldBorderColor.CGColor
        addressTextField.layer.cornerRadius = 3
        addressTextField.textColor = UIMainColor
        addressTextField.text = "Address"
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = buttonBorderColor.CGColor
        nextButton.layer.cornerRadius = 3
        nextButton.enabled = false
        autocompleteTableView.hidden = true
    }
    
    // Delegate method for tapping
    func handleTapOnView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
            UIView.animateWithDuration(0.3, animations: {
                self.textFieldsCenterYConstraint.constant += self.textFieldsView.center.y - 130
                self.textFieldsBottomConstraint.constant += self.textFieldsView.center.y - 130
                self.mapLogoTopConstraint.constant -= 300
                self.mapLogoBottomConstraint.constant += 300
                self.backButtonTopConstraint.constant -= 300
                self.autocompleteTableViewBottomConstraint.constant += self.kbHeight + 20
                self.view.layoutIfNeeded()
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                self.textFieldsTopConstraint.constant = 0
                self.textFieldsBottomConstraint.constant = 0
                self.textFieldsCenterYConstraint.constant = -20
                self.mapLogoTopConstraint.constant = 0
                self.mapLogoBottomConstraint.constant = 0
                self.autocompleteTableViewBottomConstraint.constant = 0
                self.backButtonTopConstraint.constant = 20
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // Handle location autocomplete
    func locationAutocompleterHandler(notification: NSNotification){
        autocompleteTableView.dataSource = locationAutocompleter
        autocompleteTableView.delegate = locationAutocompleter
        autocompleteTableView.hidden = false
        autocompleteTableView.reloadData()
    }
    
    func communicateAddress(address: String!){
        addressTextField.text = address
        autocompleteTableView.hidden = true
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if(touch.view.isDescendantOfView(autocompleteTableView)){
            return false
        }
        return true
    }
}


