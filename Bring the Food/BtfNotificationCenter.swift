//
//  BtfNotificationCenter.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 28/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

/// Object storing all the notifications received from the server.
/// Every notification can be inserted only once in this structure.
public class BtfNotificationCenter: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var notifications: [Int:BtfNotification]!
    private var numberOfNewNotifications : Int
    private let textCellIdentifier = "TextCell"
    private let UILightColor = UIColor(red: 0xfc/255, green: 0xf8/255, blue: 0xf1/255, alpha: 1)
    private var emptyTableView: UIView?
    private var mainMessageLabel: UILabel?
    private var secondaryMessageLabel: UILabel?
    private var requestStatus: RequestStatus?
    
    /// Loads the notifications that were previously
    /// persisted. In case no notification is found, initializes a
    /// new array containing no notifications
    public override init(){
        
        self.numberOfNewNotifications = 0
        var persistedNotifications : [Int:BtfNotification]?
        
        if RestInterface.getInstance().isLoggedIn() {
            let defaults = NSUserDefaults.standardUserDefaults()
            let key = notificationListKey+RestInterface.getInstance().getSingleAccessToken()
            persistedNotifications = defaults.dictionaryForKey(key) as! [Int:BtfNotification]?
        }
        
        if persistedNotifications != nil {
            self.notifications = persistedNotifications!
        } else {
            self.notifications = [Int:BtfNotification]()
        }
    }
    
    /// creates a notification and adds it to the list
    public func addNotification(id: Int!, label:String!, type:NotificationType!, notificationDate: Date!){
        let newNotification = BtfNotification(id: id, label: label, type:type, notificationDate: notificationDate) as BtfNotification!
        
        if(self.notifications[id] == nil){
            self.numberOfNewNotifications++
        }
        self.notifications[id] = newNotification
        
        var lowestKey = self.notifications.keys.array[0]
        while self.notifications.count > 100 {
            for tempKey in self.notifications.keys {
                if tempKey < lowestKey {
                    lowestKey = tempKey
                }
            }
            self.notifications.removeValueForKey(lowestKey)
        }
    }
    
    /// marks all the notifications in the list as "seen", and persist
    /// the list. Call this method when the view displaying the list
    /// of notifications is about to disappear.
    public func markAllAsRead(){
        for tempNotification in self.notifications {
            tempNotification.1.markAsRead()
        }
        self.numberOfNewNotifications = 0
        // Ensures data persistence to be performed immediately
        let defaults = NSUserDefaults.standardUserDefaults()
        let key = notificationListKey+RestInterface.getInstance().getSingleAccessToken()
        defaults.setObject(self.notifications, forKey: key)
        defaults.synchronize()
    }
    
    /// empties the list of notifications
    public func deleteAllNotifications(){
        self.notifications = [Int:BtfNotification]()
    }
    
    /// :returns: an array containing all the notifications currently in the list
    public func getNotifications() -> [BtfNotification]! {
        let notificationsArray = [BtfNotification](self.notifications.values)
        return notificationsArray
    }
    
    
    /// Returns the number of notifications that 
    /// haven't been displayed yet
    public func getNumberOfNewNotifications() -> Int {
        return self.numberOfNewNotifications
    }
    
    // Set number of section in table
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(notifications.count > 0){
            emptyTableView = tableView.viewWithTag(999)
            if(emptyTableView != nil){
                emptyTableView?.hidden = true
            }
            return 1
        }
        if(emptyTableView == nil){
            createEmptyView(tableView)
        }
        if(requestStatus == RequestStatus.SUCCESS || requestStatus == RequestStatus.CACHE){
            mainMessageLabel?.text = "No notifications"
            secondaryMessageLabel?.text = "Pull down to refresh"
        }
        else{
            mainMessageLabel?.text = "Network error"
            secondaryMessageLabel?.text = "Check your connectivity"
        }
        
        emptyTableView?.hidden = false
        
        return 0
    }
    
    // Set number of rows in each section
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    // Build the cell
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let notification = getNotifications()[indexPath.row]
        let typeLabel = cell.viewWithTag(1000) as! UILabel
        let descriptionLabel = cell.viewWithTag(1001) as! UILabel
        let newNotificationMark = cell.viewWithTag(1002) as UIView!
        let dateLabel = cell.viewWithTag(1003) as! UILabel
        let notificationSymbol = cell.viewWithTag(1004) as! UIImageView
        
        typeLabel.text = notification.getType().description
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = notification.getLabel()
        if(notification.isNew() == true){
                newNotificationMark.hidden = false
                cell.backgroundColor = UILightColor
        }
        else{
            newNotificationMark.hidden = true
            cell.backgroundColor = UIColor.clearColor()
        }
        dateLabel.text = "\(notification.getDaysAgo())d"
        switch notification.getType()! {
        case .DONATION_EXPIRED:
            notificationSymbol.image = UIImage(named: "expired")
        case .DONATION_EXPIRING:
            notificationSymbol.image = UIImage(named: "expiring")
        case .BOOKING_CREATED:
            notificationSymbol.image = UIImage(named: "new")
        case .BOOKING_CANCELED:
            notificationSymbol.image = UIImage(named: "cancelled")
        case .BOOKING_COLLECTED:
            notificationSymbol.image = UIImage(named: "collected")
        case .CHARITY_NO_SHOW:
            notificationSymbol.image = UIImage(named: "uncollected")
        }
        
        return cell
    }
    
    // Handle click on tableView item
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = getNotifications()[indexPath.row]
        let alert = UIAlertView()
        alert.title = notification.getType().description
        alert.message = notification.getLabel()
        alert.addButtonWithTitle("Dismiss")
        alert.show()
    }
    
    // Set section titles
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(requestStatus == RequestStatus.SUCCESS){
            return "Notifications"
        }
        if(requestStatus == RequestStatus.DEVICE_ERROR){
            return "Notifications (offline mode)"
        }
        return nil
    }

    // Display a message in case of empty table view
    private func createEmptyView(tableView: UITableView){
        emptyTableView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height))
        mainMessageLabel = UILabel()
        mainMessageLabel!.textColor = UIColor.lightGrayColor()
        mainMessageLabel!.numberOfLines = 1
        mainMessageLabel!.textAlignment = .Center
        mainMessageLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        mainMessageLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        var widthConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        mainMessageLabel!.addConstraint(widthConstraint)
        var heightConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        mainMessageLabel!.addConstraint(heightConstraint)
        var xConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterX, multiplier: 1, constant: 0)
        var yConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterY, multiplier: 1, constant: 0)
        emptyTableView!.addSubview(mainMessageLabel!)
        emptyTableView!.addConstraint(xConstraint)
        emptyTableView!.addConstraint(yConstraint)
        secondaryMessageLabel = UILabel()
        secondaryMessageLabel!.textColor = UIColor.lightGrayColor()
        secondaryMessageLabel!.numberOfLines = 1
        secondaryMessageLabel!.textAlignment = .Center
        secondaryMessageLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        secondaryMessageLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        widthConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        secondaryMessageLabel!.addConstraint(widthConstraint)
        heightConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        secondaryMessageLabel!.addConstraint(heightConstraint)
        xConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: mainMessageLabel, attribute: .CenterY, multiplier: 1, constant: 30)
        emptyTableView!.addSubview(secondaryMessageLabel!)
        emptyTableView!.addConstraint(xConstraint)
        emptyTableView!.addConstraint(yConstraint)
        emptyTableView?.tag = 999
        tableView.addSubview(emptyTableView!)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    // Set the status retrieved by rest interface for the current request
    func setRequestStatus(requestStatus: RequestStatus){
        self.requestStatus = requestStatus
    }
}


/// Represents a Notification as received from the server
public class BtfNotification: AnyObject {
    
    private let id: Int!
    private var seen: Bool!
    private let label: String!
    private let notificationDate : Date!
    private let type: NotificationType!
    
    private init(id: Int!, label:String!, type: NotificationType!, notificationDate :Date!){
        self.id = id
        self.label = label
        self.type = type
        self.notificationDate = notificationDate
        self.seen = false
    }
    
    /// :returns: the label describing the content of the notification
    public func getLabel() -> String!{
        return self.label
    }
    
    /// :returns: the label identifying the type of the notification
    public func getType() -> NotificationType!{
        return self.type
    }
    
    /// Function indicating wether the notification
    /// has never been seen by the user
    public func isNew() -> Bool! {
        return !self.seen
    }
    
    /// :returns: a day indicating the number of days passed by after the notification was issued
    public func getDaysAgo() -> Int!{
        
        let notDate = self.notificationDate.getDate()
        let currentDate = NSDate()
        let gregorian = NSCalendar.currentCalendar()
        
        let components = gregorian.components(NSCalendarUnit.CalendarUnitDay,
            fromDate: notDate,
            toDate: currentDate,
            options: nil)
        
        return components.day
    }
    
    /// Call this method when the user has seen the notification
    public func markAsRead(){
        if self.seen! {
            return
        } else {
            RestInterface.getInstance().markNotificationsAsRead(self.id)
            self.seen = true
        }
    }
}