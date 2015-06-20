//
//  Donation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public protocol Donation {

    func getDescription() -> String!
    
    func getParcelSize() -> Float!
    
    func getParcelUnit() -> ParcelUnit!
    
    func getProductDate() -> Date!
    
    func getProductType() -> ProductType!
    
    func getRemainingDays() -> Int!
    
    
    func getPhotoURL() -> String!
    
    func getSupplier() -> User!
    
}