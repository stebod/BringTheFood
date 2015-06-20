//
//  ProductType.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public enum ProductType : Printable {
    case DRIED
    case FRESH
    case COOKED
    case FROZEN
    
    public var description : String {
        switch self {
        case .DRIED: return "dried"
        case .FRESH: return "fresh"
        case .COOKED: return "cooked"
        case .FROZEN: return "frozen"
        }
    }
}



public class ProductTypeFactory{
    
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