//
//  MainTabBarController.swift
//  Bring the Food
//
//  Created by federico badini on 02/07/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    // Observers
    private weak var notificationObserver:NSObjectProtocol!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(getNotificationsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleNotifications(notification)})
        Model.getInstance().downloadMyNotifications()
    }
    
    func handleNotifications(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let notifications = Model.getInstance().getMyNotifications()
            let prova = notifications.getNumberOfNewNotifications()
            let newNotifications = notifications.getNumberOfNewNotifications()
            if(newNotifications > 0){
                (self.tabBar.items as! [UITabBarItem]!)[3].badgeValue = String(notifications.getNumberOfNewNotifications())
            }
            else{
                (self.tabBar.items as! [UITabBarItem]!)[3].badgeValue = nil
            }
        }
    }
}