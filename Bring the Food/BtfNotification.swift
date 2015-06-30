//
//  BtfNotification.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class BtfNotification: AnyObject {
    
    private let id: Int!
    private var seen: Bool!
    private let label: String!
    
    public init(id: Int!, label:String!){
        self.id = id
        self.label = label
        self.seen = false
    }
    
    public func getLabel() -> String!{
        return self.label
    }
    
    public func getId() -> Int!{
        return self.id
    }
    
    public func markAsRead(){
        if self.seen! {
            return
        } else {
            RestInterface.getInstance().markNotificationsAsRead(id)
            self.seen = true
        }
    }
}