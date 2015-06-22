//
//  ApplicationSettings.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class ApplicationSettings{
    
    private var publishedSms : Bool!
    private var publishedEmail : Bool!
    private var bookedSms: Bool!
    private var bookedEmail : Bool!
    private var retractedSms : Bool!
    private var retractedEmail : Bool!
    private var collectedSms: Bool!
    private var collectedEmail: Bool!
    private var maxDistance: Int!
    
    public init(publishedSms : Bool!, publishedEmail : Bool!, bookedSms: Bool!, bookedEmail : Bool!, retractedSms : Bool!, retractedEmail : Bool!, collectedSms: Bool!, collectedEmail: Bool!, maxDistance: Int!){
        
        self.publishedSms = publishedSms
        self.publishedEmail = publishedEmail
        self.bookedSms = bookedSms
        self.bookedEmail = bookedEmail
        self.retractedSms = retractedSms
        self.retractedEmail = retractedEmail
        self.collectedSms = collectedSms
        self.collectedEmail = collectedEmail
        self.maxDistance = maxDistance
    }
    
    public func getPublishedEmail() -> Bool! {
        return self.publishedEmail
    }

    public func getBookedEmail() -> Bool! {
        return self.bookedEmail
    }
    
    public func getRetractedEmail() -> Bool!{
        return self.retractedEmail
    }
    
    public func getCollectedEmail() -> Bool!{
        return self.collectedEmail
    }
    
    public func getMaxDistance() -> Int!{
        return self.maxDistance
    }
}