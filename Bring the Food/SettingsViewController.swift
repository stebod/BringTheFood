//
//  SettingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Observers
    private weak var userSettingsObserver: NSObjectProtocol?
    
    // Observers
    private weak var userImageObserver: NSObjectProtocol!
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    
    
    
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
    
    func fillUserData(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let user = Model.getInstance().getCurrentUser()
            nameLabel.text = user?.getName()
            imageDownloader = ImageDownloader(url: user?.getImageURL())
            // Register notification center observer
            userImageObserver = NSNotificationCenter.defaultCenter().addObserverForName(imageDownloadNotificationKey,
                object: imageDownloader,
                queue: NSOperationQueue.mainQueue(),
                usingBlock: {(notification:NSNotification!) in self.userImageHandler(notification)})
            imageDownloader?.downloadImage()
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
}