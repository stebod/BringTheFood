//
//  Donation.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class StoredDonation : NewDonation, Donation, MyDonation, OthersDonation, BookedDonation {
    
    private let id: Int!
    private let supplier: User!
    private let photo_url: String!
    private let isValid: Bool!
    private let hasOpenBookings: Bool!
    
    private var collector: User?
    private var bookingId: Int?
    
    public init(id:Int!, description: String!, parcelSize: Float!, parcelUnit: ParcelUnit!,
        productDate: Date!, productType: ProductType!, photo_url:String!, supplier: User!, isValid: Bool!, hasOpenBookings: Bool!){
            
            self.id = id
            self.supplier = supplier
            self.photo_url = photo_url
            self.isValid = isValid
            self.hasOpenBookings = hasOpenBookings
            
            super.init(description, parcelSize: parcelSize, parcelUnit: parcelUnit,
                productDate: productDate, productType: productType)
    }

    
    //*********************************************************************************
    // OTHERS DONATION PROTOCOL
    //*********************************************************************************
    
    //TODO
    public func book(){
        if !canBeModified() {
            return
        }
    }
    
    //*********************************************************************************
    // BOOKED DONATION PROTOCOL
    //*********************************************************************************
    
    //TODO
    public func unbook(){
    
    }
    
    //*********************************************************************************
    // MY DONATION PROTOCOL
    //*********************************************************************************
    
    public func getHasOpenBookings() -> Bool!{
        return hasOpenBookings
    }
    
    public func getCollector() -> User? {
        return collector
    }
    
    public func setCollector(collector : User!){
        self.collector = collector
    }
    
    public func setBookingId(bookingId : Int!){
        self.bookingId = bookingId
    }
    
    public func canBeModified() -> Bool! {
        if self.isValid! && !self.hasOpenBookings! {
            return true
        }
        return false
    }
    
    //TODO
    public func modify(){
        if !canBeModified() {
            return
        }
    }
    
    //TODO
    public func delete(){
        if !canBeModified() {
            return
        }
    }
    
    //TODO
    public func markAsCollected(){
        if !(self.isValid! && self.hasOpenBookings!){
            return
        }
    }
    
    
    //*********************************************************************************
    // DONATION PROTOCOL
    //*********************************************************************************
/*
    override public func getDescription() -> String! {
        return super.getDescription()
    }
    
    override public func getParcelSize() -> Float! {
        return super.getParcelSize()
    }
    
    override public func getParcelUnit() -> ParcelUnit! {
        return super.getParcelUnit()
    }
    
    override public func getProductDate() -> Date! {
        return super.getProductDate()
    }
    
    override public func getProductType() -> ProductType! {
        return super.getProductType()
    } */
    
    public func getRemainingDays() -> Int!{
        
        let prodDate = self.getProductDate().getDate()
        let currentDate = NSDate()
        let gregorian = NSCalendar.currentCalendar()
        
        let components = gregorian.components(NSCalendarUnit.CalendarUnitDay,
            fromDate: currentDate,
            toDate: prodDate,
            options: nil)
        
        return components.day
    }
    
    
    public func getPhotoURL() -> String! {
        return self.photo_url
    }
    
    public func getSupplier() -> User! {
        return supplier
    }
}