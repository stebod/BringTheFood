//
//  BookingsViewController.swift
//  Bring the Food
//
//  Created by federico badini on 15/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class BookingsViewController: UIViewController, DisplayBookedDetail {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Observers
    private weak var donationsObserver:NSObjectProtocol?
    private var chosenDonation: BookedDonation?
    
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
        // Register as notification center observer
        donationsObserver = NSNotificationCenter.defaultCenter().addObserverForName(getBookingsNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.fillTableView(notification)})
        Model.getInstance().downloadMyBookings()
        refreshControl.beginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(donationsObserver!)
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Set light content status bar
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if(segue.identifier == "goToBookingsDetail"){
            var vc = segue.destinationViewController as! BookedDetailViewController
            vc.donation = chosenDonation
        }
    }

    // User interface settings
    private func setUpInterface(){
        var tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView;
        tableViewController.refreshControl = self.refreshControl;
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    // Handler for tableView fill
    private func fillTableView(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        let bookingsList = Model.getInstance().getMyBookings()
        bookingsList.setRequestStatus(response!.status)
        bookingsList.delegate = self
        tableView.dataSource = bookingsList
        tableView.delegate = bookingsList
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Refresh table content
    func handleRefresh(refreshControl: UIRefreshControl) {
        Model.getInstance().downloadMyBookings()
    }
    
    // Delegate for triggering detail segue
    func displayDetail(chosenDonation: BookedDonation) {
        self.chosenDonation = chosenDonation
        performSegueWithIdentifier("goToBookingsDetail", sender: nil)
    }
    
}