//
//  Donation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// The donation protocol gives access to the 
/// essential data composing a donation
public protocol Donation {

    func getDescription() -> String!
    
    func getParcelSize() -> Float!
    
    func getParcelUnit() -> ParcelUnit!
    
    func getProductDate() -> Date!
    
    func getProductType() -> ProductType!
    
    /// :returns: the number of days left to collect the donation before it expires
    func getRemainingDays() -> Int!
    
    func getPhotoURL() -> String!
    
    /// :returns: the user who submitted the donation
    func getSupplier() -> User!
    
}