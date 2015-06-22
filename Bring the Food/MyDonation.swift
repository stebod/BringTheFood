//
//  MyDonation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public protocol MyDonation : Donation {

    func downloadDonationCollector()
    
    func getId() -> Int!
    
    func getHasOpenBookings() -> Bool!
    
    func getCollector() -> User?
    
    func modify()
    
    func delete()
    
    func markAsCollected()
    
    func canBeModified() -> Bool!
    
    func setCollector(collector : User!)
    
    func setBookingId(bookingId : Int!)
    
}