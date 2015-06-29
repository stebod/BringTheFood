//
//  BtfNotificationCenter.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 28/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation


/// Object containing all the notifications
/// currently not marked as "read"
public class BtfNotificationCenter {

    private var notifications: [Int:BtfNotification]!
    
    /// Loads the array of notifications that were previously
    /// persisted. In case no array is found, initializes a
    /// new array containing no notifications
    public init(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let persistedNotifications : [Int:BtfNotification]? = defaults.dictionaryForKey(notificationListKey) as! [Int:BtfNotification]?
        
        if persistedNotifications != nil {
            self.notifications = persistedNotifications!
        } else {
            self.notifications = [Int:BtfNotification]()
        }
    }
    
    public func addNotification(newNotification: BtfNotification!){
        self.notifications[newNotification.getId()] = newNotification
    }
    
    public func markAllAsRead(){
        for tempNotification in self.notifications {
            tempNotification.1.markAsRead()
        }
        // Ensures data persistence to be performed immediately
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.notifications, forKey: notificationListKey)
        defaults.synchronize()
    }
    
    public func deleteAllNotifications(){
        self.notifications = [Int:BtfNotification]()
    }
    
    public func getNotifications() -> [BtfNotification]! {
        let notificationsArray = [BtfNotification](self.notifications.values)
        return notificationsArray
    }
}