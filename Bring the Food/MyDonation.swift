//
//  MyDonation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

/// Contains methods which may be used only by the user who submitted the donation.
public protocol MyDonation : Donation {

    /// Send a request to the server to obtain data about the user who booked the donation
    func downloadDonationCollector()
    
    /// :returns: the id of the donation
    func getId() -> Int!
    
    /// :returns: true if the donation is currently booked by someone. Notice that a collected donation does not have any open bookings.
    func getHasOpenBookings() -> Bool!
    
    /// :returns: data about the user who booked the donation. If this method is called before downloadDonationCollector sends a success notification, this method will return nil.
    func getCollector() -> User?
    
    /// Send a rest request to modify the description and/or the size of a donation
    func modify(newDescription: String? , newParcelSize: Float?)
    
    /// Send a rest request to delete a donation
    func delete()
    
    /// Comunicates to the server that the donation has been collected by the user who booked it.
    func markAsCollected()
    
    /// :returns: true if the status of the donation allows the user who submitted it to modify it
    func canBeModified() -> Bool!
    
    /// :returns: true if the status of the donation allows the user who submitted it to mark it as collected
    func canBeCollected() -> Bool!
    
    /// Sets the given user as the collector of the donation
    func setCollector(collector : User!)
    
    /// Sets the given int as the id of the open booking on the donation
    func setBookingId(bookingId : Int!)
    
}