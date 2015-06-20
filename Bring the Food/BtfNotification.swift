//
//  BtfNotification.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class BtfNotification{
    
    private let id: Int!
    private let message: String!
    
    public init(id: Int!, message:String!){
        self.id = id
        self.message = message
    }
    
    public func getMessage() -> String{
        return self.message
    }
    
    // TODO
    public func markAsRead(){
        
    }
}