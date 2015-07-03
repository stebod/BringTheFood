//
//  BookedDonation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Contains methods which may be used only by the user who booked a donation submitted by someone else.
public protocol BookedDonation : Donation {

    /// Deletes the booking acquired on the donation
    func unbook()
    
    /// :returns: true if the booking has to be collected and if the donation is not expired, false otherwise.
    func getIsValid() -> Bool!
}