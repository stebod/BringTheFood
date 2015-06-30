//
//  ParcelUnit.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Enum describing the values that may be
/// assumed by the "parcel_unit" field of
/// a donation.
public enum ParcelUnit : Printable {
    case LITERS
    case KILOGRAMS
    case PORTIONS
    
    
    /// :returns: the string used in POST requests to communicate the "parcel_unit" data to the server
    public var description : String {
        switch self {
        case .LITERS: return "liters"
        case .KILOGRAMS: return "kg"
        case .PORTIONS: return "portions"
        }
    }
}


public class ParcelUnitFactory {
    
    /// Simple static method converting a String into a
    /// ParcelUnit value. This method should be called 
    /// when parsing the "parcel_unit" data of a
    /// response received from the server.
    public static func getParcUnitFromString(string :String)-> ParcelUnit{
        var output :ParcelUnit
        
        switch string {
        case "liters" : output = ParcelUnit.LITERS
        case "kg" : output = ParcelUnit.KILOGRAMS
        default: output = ParcelUnit.PORTIONS
        }
        
        return output
    }
}