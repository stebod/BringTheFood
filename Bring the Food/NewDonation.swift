//
//  Donation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 10/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class NewDonation{
    
    
    private let description: String!
    private let parcelSize: Float!
    private let parcelUnit: ParcelUnit!
    private let productDate: Date!
    private let productType: ProductType!
    
    
    public init(_ description: String!, parcelSize: Float!, parcelUnit: ParcelUnit!,
        productDate: Date!, productType: ProductType!){
            self.description = description
            self.parcelSize = parcelSize
            self.parcelUnit = parcelUnit
            self.productDate = productDate
            self.productType = productType
    }
    
    public func getDescription() -> String! {
        return self.description
    }
    
    public func getParcelSize() -> Float! {
        return self.parcelSize
    }
    
    public func getParcelUnit() -> ParcelUnit! {
        return self.parcelUnit
    }
    
    public func getProductDate() -> Date! {
        return self.productDate
    }
    
    public func getProductType() -> ProductType! {
        return self.productType
    }
    
}

