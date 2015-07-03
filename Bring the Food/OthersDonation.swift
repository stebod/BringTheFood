//
//  OthersDonation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Contains methods which may be used only by a user which is visualising a donation submitted by someone else.
public protocol OthersDonation : Donation{

    /// Creates a booking by the current user on the donation
    func book()
}