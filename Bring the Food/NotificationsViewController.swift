//
//  NotificationsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 01/07/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UIAlertViewDelegate {
    
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
        tableView.allowsSelection = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Unregister notification center observer
        if(notifications != nil){
            notifications!.markAllAsRead()
            if(notifications!.getNumberOfNewNotifications() == 0){
                (self.tabBarController?.tabBar.items as! [UITabBarItem])[3].badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            else{
                (self.tabBarController?.tabBar.items as! [UITabBarItem])[3].badgeValue = String(notifications!.getNumberOfNewNotifications())
                UIApplication.sharedApplication().applicationIconBadgeNumber = notifications!.getNumberOfNewNotifications()
            }
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
        
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func clearButtonPressed(sender: UIButton) {
        let alert = UIAlertView()
        alert.title = NSLocalizedString("WARNING",comment:"Warning")
        alert.message = NSLocalizedString("ERASE_ALL_MESSAGE",comment:"Erase all message")
        alert.addButtonWithTitle(NSLocalizedString("OK",comment:"Ok"))
        alert.addButtonWithTitle(NSLocalizedString("CANCEL",comment:"Cancel"))
        alert.cancelButtonIndex = 1
        alert.delegate = self
        alert.show()
    }
    
    func handleNotifications(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        notifications = Model.getInstance().getMyNotifications()
        notifications!.setRequestStatus(response!.status)
        tableView.dataSource = notifications
        tableView.delegate = notifications
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.allowsSelection = true
    }
    
    // Refresh table content
    func handleRefresh(refreshControl: UIRefreshControl) {
        Model.getInstance().downloadMyNotifications()
        tableView.allowsSelection = false
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(notifications != nil && buttonIndex == 0){
            notifications?.deleteAllNotifications()
            Model.getInstance().downloadMyNotifications()
            tableView.allowsSelection = false
            notifications!.markAllAsRead()
            if(notifications!.getNumberOfNewNotifications() == 0){
                (self.tabBarController?.tabBar.items as! [UITabBarItem])[3].badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            else{
                (self.tabBarController?.tabBar.items as! [UITabBarItem])[3].badgeValue = String(notifications!.getNumberOfNewNotifications())
                UIApplication.sharedApplication().applicationIconBadgeNumber = notifications!.getNumberOfNewNotifications()
            }
            refreshControl.beginRefreshing()
        }
    }
}
