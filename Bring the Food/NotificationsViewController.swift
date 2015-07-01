//
//  NotificationsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 01/07/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Observers
    private weak var notificationObserver:NSObjectProtocol!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(getNotificationsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleNotifications(notification)})
        Model.getInstance().downloadMyNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister notification center observer
        NSNotificationCenter.defaultCenter().removeObserver(notificationObserver!)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func handleNotifications(notification: NSNotification){
        tableView.dataSource = Model.getInstance().getMyNotifications()
        tableView.delegate = Model.getInstance().getMyNotifications()
        tableView.reloadData()
    }
}
