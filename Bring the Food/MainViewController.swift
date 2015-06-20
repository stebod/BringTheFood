//
//  MainViewController.swift
//  Bring the Food
//
//  Created by federico badini on 13/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, FilterProtocol, DisplayDetail {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Interface colors
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    
    // Private variables
    private var filterState: FilterState = FilterState()
    private var othersDonationsList: OthersDonationsList?
    private var chosenDonation: StoredDonation?
    
    // Observers
    private weak var donationsObserver: NSObjectProtocol?
    
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
        donationsObserver = NSNotificationCenter.defaultCenter().addObserverForName(getOthersDonationNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.fillTableView(notification)})
        Model.getInstance().downloadOthersDonationsList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(donationsObserver!)
        super.viewWillDisappear(animated)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if (segue.identifier == "filterContent") {
            var vc = segue.destinationViewController as! FilterViewController
            vc.delegate = self
            vc.filterState = self.filterState
        }
        else if(segue.identifier == "goToDetail"){
            var vc = segue.destinationViewController as! MainDetailViewController
            vc.donation = chosenDonation
        }
    }
    
    // User interface settings
    private func setUpInterface(){
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIMainColor], forState:.Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIMainColor], forState:.Normal)
        for item in (self.tabBarController?.tabBar.items as NSArray!){
            (item as! UITabBarItem).image = (item as! UITabBarItem).image?.imageWithRenderingMode(.AlwaysOriginal)
        }
        self.tableView.addSubview(self.refreshControl)
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    // Handler for tableView fill
    private func fillTableView(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        let othersDonationsList = Model.getInstance().getOthersDonationsList()
        othersDonationsList.setRequestStatus(response!.status)
        othersDonationsList.delegate = self
        othersDonationsList.setFilter(filterState)
        self.othersDonationsList = othersDonationsList
        tableView.dataSource = othersDonationsList
        tableView.delegate = othersDonationsList
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Refresh table content
    func handleRefresh(refreshControl: UIRefreshControl) {
        Model.getInstance().downloadOthersDonationsList()
    }
    
    // Apply filters
    func handleFiltering(filterState: FilterState) {
        self.filterState = filterState
        if (othersDonationsList != nil){
            othersDonationsList?.setFilter(filterState)
            tableView.dataSource = othersDonationsList
            tableView.delegate = othersDonationsList
            tableView.reloadData()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Delegate for triggering detail segue
    func displayDetail(chosenDonation: StoredDonation) {
        self.chosenDonation = chosenDonation
        performSegueWithIdentifier("goToDetail", sender: nil)
    }
    
}

