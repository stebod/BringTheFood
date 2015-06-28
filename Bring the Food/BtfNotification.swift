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
    private let type: NotificationType!
    
    public init(id: Int!, type: NotificationType!){
        self.id = id
        self.type = type
    }
    
    public func getTypeString() -> String!{
        return self.type.description
    }
    
    
    public func markAsRead(){
        RestInterface.getInstance().markNotificationsAsRead(id)
    }
}