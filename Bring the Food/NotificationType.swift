//
//  NotificationType.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 28/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public enum NotificationType : Printable {
    case CREATED
    case BOOKED
    case COLLECTED
    case OTHER
    
    public var description : String {
        switch self {
        case .CREATED: return "donation_created"  //TODO
        case .BOOKED: return "booking_created" 
        case .COLLECTED: return "booking_collected"
        case .OTHER: return "other"
        }
    }
}