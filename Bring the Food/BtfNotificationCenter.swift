//
//  BtfNotificationCenter.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 28/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation


/// Object storing all the notifications received from the server.
/// Every notification can be inserted only once in this structure.
public class BtfNotificationCenter {

    private var notifications: [Int:BtfNotification]!
    private var numberOfNewNotifications : Int
    
    /// Loads the notifications that were previously
    /// persisted. In case no notification is found, initializes a
    /// new array containing no notifications
    public init(){
        
        self.numberOfNewNotifications = 0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let persistedNotifications : [Int:BtfNotification]? = defaults.dictionaryForKey(notificationListKey) as! [Int:BtfNotification]?
        
        if persistedNotifications != nil {
            self.notifications = persistedNotifications!
        } else {
            self.notifications = [Int:BtfNotification]()
        }
    }
    
    /// creates a notification and adds it to the list
    public func addNotification(id: Int!, label:String!){
        let newNotification = BtfNotification(id: id, label: label) as BtfNotification!
        
        self.notifications[id] = newNotification
        self.numberOfNewNotifications++
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
        defaults.setObject(self.notifications, forKey: notificationListKey)
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
}


/// Represents a Notification as received from the server
public class BtfNotification: AnyObject {
    
    private let id: Int!
    private var seen: Bool!
    private let label: String!
    
    private init(id: Int!, label:String!){
        self.id = id
        self.label = label
        self.seen = false
    }
    
    /// :returns: the label describing the content of the notification
    public func getLabel() -> String!{
        return self.label
    }
    
    /// Function indicating wether the notification
    /// has never been seen by the user
    public func isNew() -> Bool! {
        return self.seen
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