//
//  Model.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 12/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation


/// Singleton providing access to all data of interest for
/// the application.
/// Data in the model is updated only by Model Updater
public class Model : NSObject{
    
    
    private static var instance: Model?
    private var currentUser: User?
    private var othersDonations: OthersDonationsList!
    private var myDonations: MyDonationsList!
    private var myBookings: BookingsList!
    private var settings: ApplicationSettings?
    private var myNotifications: BtfNotificationCenter!
    
    
    
    deinit{
        println("model deinit")
    }
    
    // per fare in modo che il costruttore non sia accessibile all'esterno della classe
    private override init() {
        let othersDon = [OthersDonation]()
        self.othersDonations = OthersDonationsList(othersDonationsList: othersDon)
        let myAvDon = [MyDonation]()
        let myBookedDon = [MyDonation]()
        let myHistDon = [MyDonation]()
        self.myDonations = MyDonationsList(myAvailableDonationsList: myAvDon, myBookedDonationsList: myBookedDon, myHistoricDonationsList: myHistDon)
        let currBooks = [BookedDonation]()
        let histBooks = [BookedDonation]()
        self.myBookings = BookingsList(currentBookingsList: currBooks, historicBookingsList: histBooks)
        self.myNotifications = BtfNotificationCenter()
        
        super.init()
    }
    
    public static func getInstance() -> Model{
        if(self.instance == nil){
            self.instance = Model()
        }
        return self.instance!
    }
    
    public static func clear() {
        self.instance = nil
    }
    
    //*********************************************************************************
    // USERS
    //*********************************************************************************
    
    public func downloadCurrentUser(){
        RestInterface.getInstance().getUserInfo()
    }
    
    public func getCurrentUser() -> User?{
        return self.currentUser
    }
    
    public func setCurrentUser(currentUser:User!){
        self.currentUser = currentUser
    }
    
    
    public func updateCurrentUser(username:String!, email:String!, phoneNumber:String!, addressLabel:String!){
        RestInterface.getInstance().updateUser(username, email: email, phoneNumber: phoneNumber, addressLabel: addressLabel)
    }
    
    //*********************************************************************************
    // DONATIONS
    //*********************************************************************************
    
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
    
    //*********************************************************************************
    // BOOKINGS
    //*********************************************************************************
    
    public func downloadMyBookings(){
        RestInterface.getInstance().getBookings()
    }
    
    public func getMyBookings() -> BookingsList!{
        return self.myBookings
    }
    
    public func setMyBookings(myBookings : BookingsList!){
        self.myBookings = myBookings
    }
    
    //*********************************************************************************
    // SETTINGS
    //*********************************************************************************
    
    public func downloadMySettings(){
        RestInterface.getInstance().getSettings()
    }
    
    public func getMySettings() -> ApplicationSettings? {
        return self.settings
    }
    
    public func setMySettings(mySettings : ApplicationSettings!){
        self.settings = mySettings
    }
    
    //*********************************************************************************
    // NOTIFICATIONS
    //*********************************************************************************
   
    public func downloadMyNotifications(){
        RestInterface.getInstance().getNotifications()
    }
    
    public func getMyNotifications() -> BtfNotificationCenter! {
        return self.myNotifications
    }
    
    public func setMyNotifications(notifications : BtfNotificationCenter){
        self.myNotifications = notifications
    }
}