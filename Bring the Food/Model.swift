//
//  Model.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class Model : NSObject{
    
    
    private static var instance: Model?
    private var currentUser: User?
    private var othersDonations: OthersDonationsList!
    private var myDonations: MyDonationsList!
    private var myBookings: BookingsList!
    private var settings: ApplicationSettings?
    private var myNotifications: [BtfNotification]?
    
    
    // per fare in modo che il costruttore non sia accessibile all'esterno della classe
    private override init() {
        let othersDon = [OthersDonation]()
        self.othersDonations = OthersDonationsList(othersDonationsList: othersDon)
        let myAvDon = [MyDonation]()
        let myBookedDon = [MyDonation]()
        let myHistDon = [MyDonation]()
        self.myDonations = MyDonationsList(myAvailableDonationsList: myAvDon, myBookedDonationsList: myBookedDon, myHistoricDonationsList: myHistDon)
        let myBooks = [BookedDonation]()
        self.myBookings = BookingsList(bookingsList: myBooks)
        
        super.init()
    }
    
    public static func getInstance() -> Model{
        if(self.instance == nil){
            self.instance = Model()
        }
        return self.instance!
    }
    
   
    public func downloadCurrentUser(){
        RestInterface.getInstance().getUserInfo()
    }
    
    public func getCurrentUser() -> User?{
        return self.currentUser
    }
    
    public func setCurrentUser(currentUser:User!){
        self.currentUser = currentUser
    }
    
    //TODO
    public func updateCurrentUser(){}
    
    
    public func downloadOthersDonationsList(){
        RestInterface.getInstance().getOthersDonations()
    }
    
    public func getOthersDonationsList() -> OthersDonationsList!{
        return self.othersDonations
    }
    
    public func setOthersDonationsList(othersDonationsList : OthersDonationsList!){
        self.othersDonations = othersDonationsList
    }
    
    public func downloadMyDonationsList(){
        RestInterface.getInstance().getMyDonations()
    }
    
    public func setMyDonationsList(myDonations: MyDonationsList!){
        self.myDonations = myDonations
    }
    
    public func getMyDonationsList() -> MyDonationsList!{
        return self.myDonations
    }
    
    
    public func downloadMyBookings(){
        RestInterface.getInstance().getBookings()
    }
    
    public func getMyBookings() -> BookingsList!{
        return self.myBookings
    }
    
    public func setMyBookings(myBookings : BookingsList!){
        self.myBookings = myBookings
    }
    
    public func downloadMySettings(){
        RestInterface.getInstance().getSettings()
    }
    
    public func getMySettings() -> ApplicationSettings? {
        return self.settings
    }
    
    public func setMySettings(mySettings : ApplicationSettings!){
        self.settings = mySettings
    }
    
    //TODO
    public func downloadMyNotifications(){}
    
    public func getMyNotifications() -> [BtfNotification]? {
        return self.myNotifications
    }
    
    public func setMyNotifications(notifications : [BtfNotification]!){
        self.myNotifications = notifications
    }
}