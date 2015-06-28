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
    private var bookingId: Int!
    
    public init(id:Int!, description: String!, parcelSize: Float!, parcelUnit: ParcelUnit!,
        productDate: Date!, productType: ProductType!, photo_url:String!, supplier: User!, isValid: Bool!, hasOpenBookings: Bool!){
            
            self.id = id
            self.supplier = supplier
            self.photo_url = photo_url
            self.isValid = isValid
            self.hasOpenBookings = hasOpenBookings
            self.bookingId = 0
            
            super.init(description, parcelSize: parcelSize, parcelUnit: parcelUnit,
                productDate: productDate, productType: productType)
    }

    
    public convenience init(id:Int!, description: String!, parcelSize: Float!, parcelUnit: ParcelUnit!,
        productDate: Date!, productType: ProductType!, photo_url:String!, supplier: User!, isValid: Bool!, hasOpenBookings: Bool!, collector: User!, bookingId: Int!){
            
        
            self.init(id:id, description: description, parcelSize: parcelSize, parcelUnit: parcelUnit,
                productDate: productDate, productType: productType, photo_url:photo_url, supplier: supplier, isValid: isValid, hasOpenBookings: hasOpenBookings)
            
            self.collector = collector
            self.bookingId = bookingId
    }
    
    //*********************************************************************************
    // OTHERS DONATION PROTOCOL
    //*********************************************************************************
    
    public func book(){
        if !(self.isValid! && !self.hasOpenBookings!){
            return
        }
        RestInterface.getInstance().bookCurrentDonation(self.id)
    }
    
    //*********************************************************************************
    // BOOKED DONATION PROTOCOL
    //*********************************************************************************
    
    public func unbook(){
        if !(self.isValid! && self.hasOpenBookings!){
            return
        }
        if self.bookingId == 0{
            return
        }
        RestInterface.getInstance().unbook(self.bookingId)
    }
    
    public func getIsValid() -> Bool! {
        return self.isValid
    }
    
    //*********************************************************************************
    // MY DONATION PROTOCOL
    //*********************************************************************************
    public func downloadDonationCollector(){
        if !(self.isValid! && self.hasOpenBookings!){
            return
        }
        RestInterface.getInstance().getCollectorOfDonation(self.id)
    }
    
    public func getId() -> Int! {
        return self.id
    }
    
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
    
    public func canBeCollected() -> Bool! {
        if self.isValid! && self.hasOpenBookings! {
            return true
        }
        return false
    }
    
    public func canBeModified() -> Bool! {
        if self.isValid! && !self.hasOpenBookings! {
            return true
        }
        return false
    }
    

    public func modify(newDescription: String? , newParcelSize: Float?){
        
        let desc : String!
        let parcSize : Float!
        
        if !canBeModified() {
            return
        }
        if newDescription == nil && newParcelSize == nil {
            return
        }
        if newDescription == nil {
            desc = self.getDescription()
        } else {
            desc = newDescription!
        }
        if newParcelSize == nil {
            parcSize = self.getParcelSize()
        } else {
            parcSize = newParcelSize!
        }
        RestInterface.getInstance().updateDonation(self.id, newDescription: desc, newParcelSize: parcSize)
        
    }
    
    public func delete(){
        if !(self.isValid! && !self.hasOpenBookings!) {
            return
        }
        RestInterface.getInstance().deleteDonation(self.id)
    }
    
    public func markAsCollected(){
        if !(self.isValid! && self.hasOpenBookings!){
            return
        }
        if self.bookingId == 0{
            return
        }
        RestInterface.getInstance().markBookingAsCollected(self.bookingId)
    }
    
    
    //*********************************************************************************
    // DONATION PROTOCOL
    //*********************************************************************************

    
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
    
    
    public func hasNotification(type: NotificationType) -> Bool! {
    
        switch type {
        case .CREATED :
            return Model.getInstance().getMyNotifications().isJustCreatedDonation(self.id)
        case .BOOKED :
            return Model.getInstance().getMyNotifications().isJustBookedDonation(self.id)
        case .COLLECTED :
            return Model.getInstance().getMyNotifications().isJustCollectedDonation(self.id)
        case .OTHER:
            return false
        default:
            break
            
        }
        return false
    }
}