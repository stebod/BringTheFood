//
//  SettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIAlertViewDelegate {

    // Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Observers
    private weak var userSettingsObserver: NSObjectProtocol?
    private weak var userImageObserver: NSObjectProtocol!
    private weak var logoutObserver: NSObjectProtocol!
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register as notification center observer
        userSettingsObserver = NSNotificationCenter.defaultCenter().addObserverForName(userInfoResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.fillUserData(notification)})
        Model.getInstance().downloadCurrentUser()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(userSettingsObserver!)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToChangeSettings") {
            var destViewController : ChangeSettingsViewController = segue.destinationViewController as! ChangeSettingsViewController
            destViewController.userImage = userImageView.image!
            destViewController.name = nameLabel.text!
            destViewController.email = emailLabel.text!
            destViewController.phone = phoneLabel.text!
            destViewController.address = addressLabel.text!
        }
    }
    
    @IBAction func logOutButtonPressed(sender: UIButton) {
        // Register as notification center observer
        logoutObserver = NSNotificationCenter.defaultCenter().addObserverForName(logoutResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleLogout(notification)})
        RestInterface.getInstance().logout()
    }
    
    func fillUserData(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            scrollView.hidden = false
            emptyView.hidden = true
            let user = Model.getInstance().getCurrentUser()
            nameLabel.text = user?.getName()
            emailLabel.text = user?.getEmail()
            phoneLabel.text = user?.getPhone()
            addressLabel.text = user?.getAddress().getLabel()
            imageDownloader = ImageDownloader(url: user?.getImageURL())
            // Register notification center observer
            userImageObserver = NSNotificationCenter.defaultCenter().addObserverForName(imageDownloadNotificationKey,
                object: imageDownloader,
                queue: NSOperationQueue.mainQueue(),
                usingBlock: {(notification:NSNotification!) in self.userImageHandler(notification)})
            imageDownloader?.downloadImage()
        }
        else{
            scrollView.hidden = true
            emptyView.hidden = false
        }
    }
    
    func userImageHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let image = imageDownloader!.getImage()
            userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
            userImageView.clipsToBounds = true
            userImageView.layer.borderWidth = 3.0;
            userImageView.layer.borderColor = UIMainColor.CGColor
            // Use smallest side length as crop square length
            var squareLength = min(image!.size.width, image!.size.height)
            var clippedRect = CGRectMake((image!.size.width - squareLength) / 2, (image!.size.height - squareLength) / 2, squareLength, squareLength)
            userImageView.contentMode = UIViewContentMode.ScaleAspectFill
            userImageView.image = UIImage(CGImage: CGImageCreateWithImageInRect(image!.CGImage, clippedRect))
        }

    }
    
    func handleLogout(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Impossible to logout"
            alert.message = "The impossible happened"
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
            let appDelegate = UIApplication.sharedApplication().delegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
            if appDelegate!.window != nil {
                appDelegate!.window!!.rootViewController = rootViewController
            }
        }
        NSNotificationCenter.defaultCenter().removeObserver(logoutObserver)
    }
    
    private func setUpInterface(){
        addressLabel.numberOfLines = 2
        var leftConstraint = NSLayoutConstraint(item: contentView!, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        var rightConstraint = NSLayoutConstraint(item: contentView!, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        self.view.addConstraint(rightConstraint)
        emptyView.hidden = true
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}