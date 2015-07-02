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
    
    // Private variables
    private var notifications: BtfNotificationCenter?

    // Refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let refreshControlColor = UIColor(red: 0xfe/255, green: 0xfa/255, blue: 0xf3/255, alpha: 1)
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = refreshControlColor
        return refreshControl
        }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(getNotificationsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleNotifications(notification)})
        Model.getInstance().downloadMyNotifications()
        refreshControl.beginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister notification center observer
        if(notifications != nil){
            notifications!.markAllAsRead()
        }
        NSNotificationCenter.defaultCenter().removeObserver(notificationObserver!)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setUpInterface(){
        var tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView;
        tableViewController.refreshControl = self.refreshControl;
    }
    
    func handleNotifications(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        notifications = Model.getInstance().getMyNotifications()
        notifications!.setRequestStatus(response!.status)
        tableView.dataSource = notifications
        tableView.delegate = notifications
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Refresh table content
    func handleRefresh(refreshControl: UIRefreshControl) {
        Model.getInstance().downloadMyNotifications()
    }
}
