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

    private var newDonationNotifications: [Int:BtfNotification]
    private var newBookingNotifications: [Int:BtfNotification]
    private var bookingCollectedNotifications: [Int:BtfNotification]
    
    /// Initializes an object containing no notifications
    public init(){
        self.newDonationNotifications = [Int:BtfNotification]()
        self.newBookingNotifications = [Int:BtfNotification]()
        self.bookingCollectedNotifications = [Int:BtfNotification]()
    }

    /// Initializes an object containing the given dictionaries of notifications
    /// The Dictionaries passed as parameters have to be indexed by the id of the
    /// donation to which the notification refers.
    public init(newDonationNotifications : [Int:BtfNotification]!,
        newBookingNotifications : [Int:BtfNotification]!,
        bookingCollectedNotifications : [Int:BtfNotification]!){
            
        self.newDonationNotifications = newDonationNotifications
        self.newBookingNotifications = newBookingNotifications
        self.bookingCollectedNotifications = bookingCollectedNotifications
    }
    
    /// Call this method when the "Explore" tab is displayed
    public func markAllNewDonationsAsRead(){
        for tempNotification in newDonationNotifications {
            tempNotification.1.markAsRead()
        }
    }

    /// Call this method when the "My Donations" tab is displayed
    public func markAllNewBookingsAsRead(){
        for tempNotification in newBookingNotifications {
            tempNotification.1.markAsRead()
        }
    }
    
    /// Call this method when the "My Bookings" tab is displayed
    public func markAllCollectedAsRead(){
        for tempNotification in bookingCollectedNotifications {
            tempNotification.1.markAsRead()
        }
    }
    
    /// :returns: true if there is a notification of type NotificationType.CREATED on the donation identified by the id
    public func isJustCreatedDonation(donationId: Int!) -> Bool!{
        return newDonationNotifications[donationId] != nil
    }

    /// :returns: true if there is a notification of type NotificationType.BOOKED on the booking identified by the id
    public func isJustBookedDonation(bookingId: Int!) -> Bool!{
        return newBookingNotifications[bookingId] != nil
    }
    
    /// :returns: true if there is a notification of type NotificationType.COLLECTED on the booking identified by the id
    public func isJustCollectedDonation(bookingId: Int!) -> Bool!{
        return bookingCollectedNotifications[bookingId] != nil
    }
    
    /// :returns: the number of notifications about new donations
    public func getNumberOfCreatedNotifications() -> Int!{
        return newDonationNotifications.count
    }
    
    /// :returns: the number of notifications about new bookings
    public func getNumberOfBookedNotifications() -> Int!{
        return newBookingNotifications.count
    }
    
    /// :returns: the number of notifications about bookings collected
    public func getNumberOfCollectedNotifications() -> Int!{
        return bookingCollectedNotifications.count
    }
}