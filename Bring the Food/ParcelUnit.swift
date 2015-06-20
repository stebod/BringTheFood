//
//  ParcelUnit.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public enum ParcelUnit : Printable {
    case LITERS
    case KILOGRAMS
    case PORTIONS
    
    public var description : String {
        switch self {
        case .LITERS: return "liters"
        case .KILOGRAMS: return "kg"
        case .PORTIONS: return "portions"
        }
    }
}

public class ParcelUnitFactory {
    
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