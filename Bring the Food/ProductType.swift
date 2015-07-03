//
//  ProductType.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Enum describing the values that may be
/// assumed by the "product_type" field of
/// a donation.
public enum ProductType : Printable {
    case DRIED
    case FRESH
    case COOKED
    case FROZEN
    
    /// :returns: the string used in POST requests to communicate the "product_type" data to the server
    public var description : String {
        switch self {
        case .DRIED: return NSLocalizedString("DRIED",comment:"dried")
        case .FRESH: return NSLocalizedString("FRESH",comment:"fresh")
        case .COOKED: return NSLocalizedString("COOKED",comment:"cooked")
        case .FROZEN: return NSLocalizedString("FROZEN",comment:"frozen")
        }
    }
}



public class ProductTypeFactory{
    
    /// Simple static method converting a String into a
    /// ProductType value. This method should be called
    /// when parsing the "product_type" data of a
    /// response received from the server.
    public static func getProdTypeFromString(string :String)-> ProductType{
        var output :ProductType
        
        switch string {
        case "dried" : output = ProductType.DRIED
        case "fresh" : output = ProductType.FRESH
        case "cooked" : output = ProductType.COOKED
        default: output = ProductType.FROZEN
        }
        
        return output
    }
}