//
//  User.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class User{
    
    private let id : Int!
    private let email: String!
    private let name: String!
    private let phone: String!
    private let address: Address!
    private let imageURL: String!
    
    
    public init(id: Int!, email: String!, name: String!, phone: String!, address: Address!, imageURL: String!){
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.address = address
        self.imageURL = imageURL
    }
    
    public func getId()-> Int! {
        return self.id
    }
    
    public func getEmail() -> String! {
        return self.email
    }
    
    public func getName()-> String! {
        return self.name
    }
    
    public func getPhone() -> String! {
        return self.phone
    }
    
    public func getAddress() -> Address! {
        return self.address
    }
    
    public func getImageURL() -> String! {
        return self.imageURL
    }
}