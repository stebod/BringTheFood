//
//  Address.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class Address {
    
    private var label: String!
    private var latitude: Float?
    private var longitude: Float?
    
    public init(label: String!){
        self.label = label
    }
    
    public init(label: String!, latitude: Float!, longitude:Float!){
        
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
    public func getLabel() -> String!{
        return self.label
    }
    
    public func getLatitude() -> Float? {
        return self.latitude
    }
    
    public func getLongitude() -> Float? {
        return self.longitude
    }
}