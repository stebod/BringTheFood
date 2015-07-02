//
//  NotificationType.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 02/07/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Enum describing the values that may be
/// assumed by the "notification_type" field of
/// a notification.
public enum NotificationType : Printable {
    case DONATION_EXPIRED
    case DONATION_EXPIRING
    case BOOKING_CREATED
    case BOOKING_CANCELED
    case BOOKING_COLLECTED
    case CHARITY_NO_SHOW
    
    /// :returns: the string used in POST requests to communicate the "notification_type" data to the server
    public var description : String {
        switch self {
        case .DONATION_EXPIRED: return "Donation expired"
        case .DONATION_EXPIRING: return "Donation expiring"
        case .BOOKING_CREATED: return "Booking created"
        case .BOOKING_CANCELED: return "Booking canceled"
        case .BOOKING_COLLECTED: return "Booking collected"
        case .CHARITY_NO_SHOW: return "Uncollected donation"
        }
    }
}



public class NotificationTypeFactory{
    
    /// Simple static method converting a String into a
    /// NotificationType value. This method should be called
    /// when parsing the "notification_type" data of a
    /// response received from the server.
    public static func getNotificationTypeFromString(string :String)-> NotificationType{
        var output :NotificationType
        
        switch string {
        case "donation_expired" : output = NotificationType.DONATION_EXPIRED
        case "donation_expiring" : output = NotificationType.DONATION_EXPIRING
        case "booking_created" : output = NotificationType.BOOKING_CREATED
        case "booking_canceled" : output = NotificationType.BOOKING_CANCELED
        case "booking_collected" : output = NotificationType.BOOKING_COLLECTED
        default: output = NotificationType.CHARITY_NO_SHOW
        }
        
        return output
    }
}