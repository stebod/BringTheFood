//
//  ModelUpdater.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 13/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class ModelUpdater : NSObject{
    
    private static var instance: ModelUpdater?
    
    // per fare in modo che il costruttore non sia accessibile all'esterno della classe
    private override init() {
        super.init()
    }
    
    public static func getInstance() -> ModelUpdater{
        if(self.instance == nil){
            self.instance = ModelUpdater()
        }
        return self.instance!
    }
    
    
    public func notifyNotLoggedInError(notification_key : String ){
        
        println("not logged in")
        NSNotificationCenter.defaultCenter().postNotificationName(
            notification_key,
            object: self,
            userInfo: ["info" : HTTPResponseData(RequestStatus.NOT_LOGGED_IN)]
        )
    }
    
    public func notifyDeviceError(notification_key : String ){
        
        println("device error")
        NSNotificationCenter.defaultCenter().postNotificationName(
            notification_key,
            object: self,
            userInfo: ["info" : HTTPResponseData(RequestStatus.DEVICE_ERROR)]
        )
        
    }
    
    public func notifyNetworkError(notification_key : String){
        
        println("network error")
        NSNotificationCenter.defaultCenter().postNotificationName(
            notification_key,
            object: self,
            userInfo: ["info" : HTTPResponseData(RequestStatus.NETWORK_ERROR)]
        )
    }
    
    public func notifyDataError(notification_key : String){
        
        println("data error")
        NSNotificationCenter.defaultCenter().postNotificationName(
            notification_key,
            object: self,
            userInfo: ["info" : HTTPResponseData(RequestStatus.DATA_ERROR)]
        )
    }
    
    public func notifySuccess(notification_key : String, data : NSData, cachedResponse : Bool!){
        
        //parsing json
        var jsonError: NSError?
        let parsedJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
        
        if (jsonError == nil && parsedJson != nil){
            let json = parsedJson as! NSDictionary
            let success : Bool = json["success"] as! Bool
            if(success){
                
                handleData(notification_key, json: json)
                
                if !cachedResponse! {
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        notification_key,
                        object: self,
                        userInfo: ["info" : HTTPResponseData(RequestStatus.SUCCESS)]
                    )
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        notification_key,
                        object: self,
                        userInfo: ["info" : HTTPResponseData(RequestStatus.CACHE)]
                    )
                }
            }
            else{
                //if !success
                notifyDataError(notification_key)
                println((json.valueForKeyPath("result.errors") as! NSArray))
            }
        }
        else{
            //if jsonError != nil
            notifyDataError(notification_key)
        }
    }
    
    
    private func handleData(notification_key : String, json : NSDictionary!){
        
        //var listaerrori : NSArray = json.valueForKeyPath("result.errors") as! NSArray
        
        switch notification_key {
            
        case loginResponseNotificationKey :
            let userId = json.valueForKeyPath("result.user_id") as! Int
            let singleAccessToken = json.valueForKeyPath("result.single_access_token") as! String
            RestInterface.getInstance().setUserCredentials(userId, singleAccessToken: singleAccessToken)
            
        case getMyDonationNotificationKey :
            var availableDonationList = [MyDonation]()
            var bookedDonationList = [MyDonation]()
            var historicDonationList = [MyDonation]()
            var resultList : [NSDictionary]! = json["result"] as! [NSDictionary]!
            for e in resultList {
                
                // general info about the donation
                let donId = e["id"] as! Int!
                let donDescription = e["description"] as! String!
                let donParcelSize = e["parcel_size"] as! Float!
                let donParcelUnit = ParcelUnitFactory.getParcUnitFromString(e["unit"] as! String!)
                let untilDate = e["until"] as! String!
                let donProductDate = Date(dateString: prefix(untilDate, 10))
                let donProductType = ProductTypeFactory.getProdTypeFromString(e["product_type"] as! String!)
                let donPhotoUrl = e.valueForKeyPath("photo.medium") as! String!
                
                //Address of the donation
                let addressLabel = e.valueForKeyPath("address.label") as! String!
                let addressLatitude = e.valueForKeyPath("address.latitude") as! Float!
                let addressLongitude = e.valueForKeyPath("address.longitude") as! Float!
                var tempAddress = Address(label: addressLabel, latitude: addressLatitude,
                    longitude: addressLongitude)
                
                // Supplier of the donation
                
                let supId = e.valueForKeyPath("supplier.id") as! Int!
                let supEmail = e.valueForKeyPath("supplier.email") as! String!
                let supName = e.valueForKeyPath("supplier.name") as! String!
                let supPhone = e.valueForKeyPath("supplier.phone") as! String!
                let supImageURL = e.valueForKeyPath("supplier.avatar") as! String!
                
                let supplier = User(id: supId, email: supEmail, name: supName, phone: supPhone, address: tempAddress, imageURL: supImageURL)
                
                let isValid:Bool = e["live"] as! Bool!
                let isBooked:Bool = e["has_open_bookings"] as! Bool!
                
                var tempDonation = StoredDonation(id: donId, description: donDescription, parcelSize: donParcelSize, parcelUnit: donParcelUnit, productDate: donProductDate, productType: donProductType, photo_url: donPhotoUrl, supplier: supplier, isValid: isValid, hasOpenBookings: isBooked)
                
                
                if(isValid){
                    if(isBooked){
                        //aggiungere temp a bookedDonationList
                        bookedDonationList.append(tempDonation)
                    } else {
                        //aggiungere temp a availableDonationList
                        availableDonationList.append(tempDonation)
                    }
                } else {
                    //aggiungere temp a historicDonationList
                    historicDonationList.append(tempDonation)
                }
                
            }
            
            let myList = MyDonationsList(myAvailableDonationsList: availableDonationList,myBookedDonationsList: bookedDonationList,myHistoricDonationsList: historicDonationList)
            Model.getInstance().setMyDonationsList(myList)
            
        case getOthersDonationNotificationKey :
            var othersDonationList = [OthersDonation]()
            var resultList : [NSDictionary]! = json["result"] as! [NSDictionary]!
            for e in resultList {
                
                
                let isValid:Bool = e["live"] as! Bool!
                let isBooked:Bool = e["has_open_bookings"] as! Bool!
                
                if isValid && !isBooked {
                
                    // general info about the donation
                    let donId = e["id"] as! Int!
                    let donDescription = e["description"] as! String!
                    let donParcelSize = e["parcel_size"] as! Float!
                    let donParcelUnit = ParcelUnitFactory.getParcUnitFromString(e["unit"] as! String!)
                    let donProductDate = Date(dateString: (e["product_date"] as! String!))
                    let donProductType = ProductTypeFactory.getProdTypeFromString(e["product_type"] as! String!)
                    let donPhotoUrl = e.valueForKeyPath("photo.medium") as! String!
                    
                    //Address of the donation
                    let addressLabel = e.valueForKeyPath("address.label") as! String!
                    let addressLatitude = e.valueForKeyPath("address.latitude") as! Float!
                    let addressLongitude = e.valueForKeyPath("address.longitude") as! Float!
                    var tempAddress = Address(label: addressLabel, latitude: addressLatitude,
                        longitude: addressLongitude)
                    
                    // Supplier of the donation
                    
                    let supId = e.valueForKeyPath("supplier.id") as! Int!
                    let supEmail = e.valueForKeyPath("supplier.email") as! String!
                    let supName = e.valueForKeyPath("supplier.name") as! String!
                    let supPhone = e.valueForKeyPath("supplier.phone") as! String!
                    let supImageURL = e.valueForKeyPath("supplier.avatar") as! String!
                    
                    let supplier = User(id: supId, email: supEmail, name: supName, phone: supPhone, address: tempAddress, imageURL: supImageURL)
                    
                    var tempDonation = StoredDonation(id: donId, description: donDescription, parcelSize: donParcelSize, parcelUnit: donParcelUnit, productDate: donProductDate, productType: donProductType, photo_url: donPhotoUrl, supplier: supplier, isValid: isValid, hasOpenBookings: isBooked)
                    
                    othersDonationList.append(tempDonation)
                }
                
            }
            
            let otherList = OthersDonationsList(othersDonationsList: othersDonationList)
            Model.getInstance().setOthersDonationsList(otherList)
            
        case userInfoResponseNotificationKey :
            let addressLabel = json.valueForKeyPath("result.address.label") as! String!
            let addressLatitude = json.valueForKeyPath("result.address.latitude") as! Float!
            let addressLongitude = json.valueForKeyPath("result.address.longitude") as! Float!
            var userAddress = Address(label: addressLabel, latitude: addressLatitude,
                longitude: addressLongitude)
        
            let userId = json.valueForKeyPath("result.id") as! Int!
            let userEmail = json.valueForKeyPath("result.email") as! String!
            let userName = json.valueForKeyPath("result.name") as! String!
            let userPhone = json.valueForKeyPath("result.phone") as! String!
            let userImageURL = json.valueForKeyPath("result.avatar") as! String!
        
            let user = User(id: userId, email: userEmail, name: userName, phone: userPhone, address: userAddress, imageURL: userImageURL)
            Model.getInstance().setCurrentUser(user)
            
        case getSettingsResponseNotificationKey :
            println("stop")
            let localeString = json.valueForKeyPath("result.lang.locale") as! String!
            let maxDistance = json.valueForKeyPath("result.charity.range") as! Int!
           
            let publishedSms = json.valueForKeyPath("result.notify_me_when.published.sms") as! Bool!
            let publishedEmail = json.valueForKeyPath("result.notify_me_when.published.email") as! Bool!
            let bookedSms = json.valueForKeyPath("result.notify_me_when.booked.sms") as! Bool!
            let bookedEmail = json.valueForKeyPath("result.notify_me_when.booked.email") as! Bool!
            let retractedSms = json.valueForKeyPath("result.notify_me_when.retracted.sms") as! Bool!
            let retractedEmail = json.valueForKeyPath("result.notify_me_when.retracted.email") as! Bool!
            let collectedSms = json.valueForKeyPath("result.notify_me_when.collected.sms") as! Bool!
            let collectedEmail = json.valueForKeyPath("result.notify_me_when.collected.email") as! Bool!
        case getBookingsNotificationKey :
            var bookings = [BookedDonation]()
            let bookingsList = BookingsList(bookingsList: bookings)
            Model.getInstance().setMyBookings(bookingsList)
            
        default: break
            
        }
    }
}