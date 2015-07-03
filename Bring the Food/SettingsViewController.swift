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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Observers
    private weak var userSettingsObserver: NSObjectProtocol?
    private weak var userImageObserver: NSObjectProtocol!
    private weak var logoutObserver: NSObjectProtocol!
    
    // Refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let refreshControlColor = UIColor(red: 0xfe/255, green: 0xfa/255, blue: 0xf3/255, alpha: 1)
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = refreshControlColor
        return refreshControl
        }()
    
    // Private variables
    private var emptyView: UIView?
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    private var deltaLength: CGFloat?
    
    
    
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
        refreshControl.beginRefreshing()
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
            editButton.hidden = false
            contentView.hidden = false
            emptyView?.hidden = true
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
            contentView.hidden = true
            if(emptyView == nil){
                createEmptyView()
            }
            emptyView?.hidden = false
        }
        refreshControl.endRefreshing()
    }
    
    // Display a message in case of empty table view
    func createEmptyView(){
        let emptyViewWidth = UIScreen.mainScreen().bounds.width
        let emptyViewHeight = UIScreen.mainScreen().bounds.height - headerView.bounds.height - 49
        emptyView = UIView(frame: CGRectMake(0, 0, emptyViewWidth, emptyViewHeight))
        let mainMessageLabel = UILabel()
        mainMessageLabel.textColor = UIColor.lightGrayColor()
        mainMessageLabel.numberOfLines = 1
        mainMessageLabel.textAlignment = .Center
        mainMessageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        mainMessageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        mainMessageLabel.text = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
        var widthConstraint = NSLayoutConstraint(item: mainMessageLabel, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        mainMessageLabel.addConstraint(widthConstraint)
        var heightConstraint = NSLayoutConstraint(item: mainMessageLabel, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        mainMessageLabel.addConstraint(heightConstraint)
        var xConstraint = NSLayoutConstraint(item: mainMessageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: emptyView, attribute: .CenterX, multiplier: 1, constant: 0)
        var yConstraint = NSLayoutConstraint(item: mainMessageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: emptyView, attribute: .CenterY, multiplier: 1, constant: 0)
        emptyView!.addSubview(mainMessageLabel)
        emptyView!.addConstraint(xConstraint)
        emptyView!.addConstraint(yConstraint)
        let secondaryMessageLabel = UILabel()
        secondaryMessageLabel.textColor = UIColor.lightGrayColor()
        secondaryMessageLabel.numberOfLines = 1
        secondaryMessageLabel.textAlignment = .Center
        secondaryMessageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        secondaryMessageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        secondaryMessageLabel.text =  NSLocalizedString("CHECK_CONNECTIVITY",comment:"Check connectivity")
        widthConstraint = NSLayoutConstraint(item: secondaryMessageLabel, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        secondaryMessageLabel.addConstraint(widthConstraint)
        heightConstraint = NSLayoutConstraint(item: secondaryMessageLabel, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        secondaryMessageLabel.addConstraint(heightConstraint)
        xConstraint = NSLayoutConstraint(item: secondaryMessageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: emptyView, attribute: .CenterX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: secondaryMessageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: mainMessageLabel, attribute: .CenterY, multiplier: 1, constant: 30)
        emptyView!.addSubview(secondaryMessageLabel)
        emptyView!.addConstraint(xConstraint)
        emptyView!.addConstraint(yConstraint)
        deltaLength = contentView.bounds.height - emptyViewHeight
        bottomLayoutConstraint.constant -= deltaLength!
        xConstraint = NSLayoutConstraint(item: emptyView!, attribute: .CenterX, relatedBy: .Equal, toItem: scrollView, attribute: .CenterX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: emptyView!, attribute: .CenterY, relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1, constant: 0)
        scrollView.addSubview(emptyView!)
        scrollView.addConstraint(xConstraint)
        scrollView.addConstraint(yConstraint)
        scrollView.alwaysBounceVertical = true
        scrollView.layoutIfNeeded()
    }
    
    func userImageHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let image = imageDownloader!.getImage()
            if(image != nil){
                userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
                userImageView.clipsToBounds = true
                userImageView.layer.borderWidth = 3.0;
                userImageView.layer.borderColor = UIMainColor.CGColor
                // Use smallest side length as crop square length
                var squareLength = min(image!.size.width, image!.size.height)
                var clippedRect = CGRectMake((image!.size.width - squareLength) / 2, (image!.size.height -      squareLength) / 2, squareLength, squareLength)
                userImageView.contentMode = UIViewContentMode.ScaleAspectFill
                userImageView.image = UIImage(CGImage: CGImageCreateWithImageInRect(image!.CGImage, clippedRect))
            }
        }
    }
    
    func handleLogout(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = NSLocalizedString("LOGOUT_ERROR",comment:"Logout error")
            alert.message = NSLocalizedString("LOGOUT_ERROR_MESSAGE",comment:"Logout error message")
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
        else{
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.removeNotificationObserver()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
            if appDelegate.window != nil {
                appDelegate.window!.rootViewController = rootViewController
            }
        }
        NSNotificationCenter.defaultCenter().removeObserver(logoutObserver)
    }
    
    private func setUpInterface(){
        editButton.hidden = true
        addressLabel.numberOfLines = 2
        var leftConstraint = NSLayoutConstraint(item: contentView!, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        var rightConstraint = NSLayoutConstraint(item: contentView!, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        self.view.addConstraint(rightConstraint)
        self.scrollView.addSubview(self.refreshControl)
        contentView.hidden = true
    }
    
    // Refresh table content
    func handleRefresh(refreshControl: UIRefreshControl) {
        Model.getInstance().downloadCurrentUser()
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}