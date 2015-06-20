//
//  FilterState.swift
//  Bring the Food
//
//  Created by federico badini on 18/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public struct FilterState{
    var isFreshFood: Bool
    var isCookedFood: Bool
    var isDriedFood: Bool
    var isFrozenFood: Bool
    var expiration: Int
    
    public init(){
        isFreshFood = true
        isCookedFood = true
        isDriedFood = true
        isFrozenFood = true
        expiration = 60
    }
}