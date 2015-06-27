//
//  RestInterface.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 03/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

public class RestInterface : NSObject{
    
    private let serverAddress: String = "http://dev.ict4g.org/btf/api/v2"
    private let securityToken: String = "e01228ed4aee2b0cd103fa0962f4589a"
    
    
    private var userId: Int = 0
    private var singleAccessToken: String = ""
    private let imageCache : NSURLCache
    private var imageSession : NSURLSession!
    private static var instance: RestInterface?
    
    // per fare in modo che il costruttore non sia accessibile all'esterno della classe
    // imposta anche il caching
    private override init() {
        
        let memoryCapacity : Int = 20*1024*1024
        let diskCapacity : Int = 100*1024*1024
        self.imageCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "ImageDownloadCache")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        configuration.URLCache = self.imageCache
        self.imageSession = NSURLSession(configuration: configuration)
        super.init()
    }
    
    public static func getInstance() -> RestInterface{
        if(self.instance == nil){
            self.instance = RestInterface()
        }
        return self.instance!
    }
    
    
    //*********************************************************************************
    // CREDENTIALS STORAGE
    //*********************************************************************************
    
    public func isLoggedIn() -> Bool {
        if self.singleAccessToken != "" {
            return true
        }
        //deleteCredentials()
        return loadCredentials()
    }
    
    public func setUserCredentials(userId : Int, singleAccessToken:String){
        self.userId = userId
        self.singleAccessToken = singleAccessToken
        storeCredentials(userId, singleAccessToken: singleAccessToken)
    }
    
    public func handleLogoutSucceded(){
        singleAccessToken = ""
        userId = 0
        deletePersistedData()
        clearImageCache()
    }
    
    private func storeCredentials(userId : Int, singleAccessToken:String){

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(singleAccessToken, forKey: singleAccessTokenKey)
        defaults.setInteger(userId, forKey: userIdKey)
    }
    
    // Ritorna vero se il caricamento delle credenziali ha avuto successo, falso altrimenti
    private func loadCredentials() -> Bool {

        //deleteurlcache()
        let defaults = NSUserDefaults.standardUserDefaults()
        let singleAccessToken = defaults.stringForKey(singleAccessTokenKey)
        let userId = defaults.integerForKey(userIdKey)
        if singleAccessToken != nil
        {
            self.singleAccessToken = singleAccessToken!
            self.userId = userId
        }
        return (self.singleAccessToken != "") && (self.userId != 0)
    }
    
    // Da chiamare in seguito al logout, cancella tutte le credenziali salvate
    private func deletePersistedData() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("", forKey: singleAccessTokenKey)
        defaults.setInteger(0, forKey: userIdKey)
        
        deleteurlcache()

        defaults.synchronize()
    }
    
    private func deleteurlcache() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: getMyDonationNotificationKey)
        defaults.setObject(nil, forKey: getOthersDonationNotificationKey)
        defaults.setObject(nil, forKey: getBookingsNotificationKey)
        
    }
    
    //*********************************************************************************
    // DONATIONS
    //*********************************************************************************
    
    public func createDonation(donation:NewDonation!){
        
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations" + parameters)!)
            request.HTTPMethod = "POST"
            
            //preparo il body
            var postString = "{ \"donation\" : {  "
            postString += "\"description\": \"\(donation.getDescription())\","
            postString += "\"parcel_size\": \(donation.getParcelSize()),"
            postString += "\"unit\": \"\(donation.getParcelUnit().description)\","
            postString += "\"product_date\": \"\(donation.getProductDate().getDateString())\","
            postString += "\"product_type\": \"\(donation.getProductType().description)\""
            postString += " } } "
            println(postString)
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            sendRequest(request, notification_key: donationCreatedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(donationCreatedNotificationKey)
        }
    }
    
    public func getOthersDonations(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations/" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getOthersDonationNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getOthersDonationNotificationKey)
        }
    }
    
    public func getMyDonations(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/my_donations/" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getMyDonationNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getMyDonationNotificationKey)
        }
    }
    
    public func getDonationWithId(donation_id: Int){
        if(isLoggedIn()){
            var parameters:String = "\(donation_id)" +
            "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations/" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getSingleDonationNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getSingleDonationNotificationKey)
        }
    }
    
    public func deleteDonation(donation_id: Int){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations/\(donation_id)" + parameters)!)
            request.HTTPMethod = "DELETE"
            sendRequest(request, notification_key: donationDeletedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(donationDeletedNotificationKey)
        }
    }
    
    
    //*********************************************************************************
    // BOOKINGS
    //*********************************************************************************
    
    public func getBookings(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/my_bookings/" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getBookingsNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getBookingsNotificationKey)
        }
    }
    
    public func getCollectorOfDonation(donationId: Int!){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations/\(donationId)/bookings" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getCollectorOfDonationNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getCollectorOfDonationNotificationKey)
        }
    }
    
    public func bookCurrentDonation(donationId : Int!){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/donations/\(donationId)/bookings" + parameters)!)
            request.HTTPMethod = "POST"
            
            //preparo il body
            var postString = "{ \"booking\" : {  "
            postString += "\"parcels\": 1 "
            postString += " } } "
            println(postString)
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            sendRequest(request, notification_key: bookingCreatedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(bookingCreatedNotificationKey)
        }
    }
    
    public func unbook(bookingId : Int!){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/bookings/\(bookingId)" + parameters)!)
            request.HTTPMethod = "DELETE"
            sendRequest(request, notification_key: unbookedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(unbookedNotificationKey)
        }
    }
    
    public func markBookingAsCollected(bookingId : Int!){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/bookings/\(bookingId)/collect" + parameters)!)
            request.HTTPMethod = "POST"
            
            //preparo il body
            var postString = "{ \"booking\" : {  "
            postString += " } } "
            println(postString)
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            sendRequest(request, notification_key: bookingCollectedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(bookingCollectedNotificationKey)
        }
    }
    
    //*********************************************************************************
    // USERS
    //*********************************************************************************
    
    public func sendLoginData(email:String!, password:String!){
        
        var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/login")!)
        request.HTTPMethod = "POST"
        
        //preparo il body
        let postString = "{"
            + "\"email\": \"\(email)\","
            + "\"password\": \"\(password)\""
            + "}"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        sendRequest(request, notification_key: loginResponseNotificationKey)
    }
    
    public func createUser(username:String!, password:String!, email:String!, phoneNumber:String!, avatar: UIImage?, addressLabel:String!){
        
        let localeString:String!
        let locale :String = NSLocale.preferredLanguages()[0] as! String
        if locale == "it" {
            localeString = "it"
        } else {
            localeString = "en"
        }
        
        var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/users")!)
        request.HTTPMethod = "POST"
        
        //preparo il body
        var postString = "{ "
        postString += " \"user\": { "
        postString += " \"name\": \"\(username)\", "
        postString += " \"password\": \"\(password)\", "
        postString += " \"password_confirmation\": \"\(password)\", "
        postString += " \"email\": \"\(email)\", "
        postString += " \"phone\": \"\(phoneNumber)\", "
        postString += " \"type\": \"Peer\", "
        postString += " \"locale\": \"\(localeString)\", "
        
        if avatar != nil {
            let imageData = UIImageJPEGRepresentation(avatar, 0)
            let base64Avatar = imageData.base64EncodedStringWithOptions(.allZeros)
            postString += " \"avatar\": \"\(base64Avatar)\", "
        }
        
        postString += " \"address\" : {  "
        postString += " \"label\": \"\(addressLabel)\" "
        postString += "} } } "
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        sendRequest(request, notification_key: createUserNotificationKey)
    }
    
    public func changePassword(old_password: String!, new_password:String!){
        
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/change_password" + parameters)!)
            request.HTTPMethod = "POST"
            
            //preparo il body                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
            let postString = "{"
                + "\"old_password\": \"\(old_password)\","
                + "\"password\": \"\(new_password)\""
                + "\"password_confirmation\": \"\(new_password)\""
                + "}"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            sendRequest(request, notification_key: passwordChangedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(passwordChangedNotificationKey)
        }
    }
    
    public func logout(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/logout" + parameters)!)
            request.HTTPMethod = "GET"
            
            sendRequest(request, notification_key: logoutResponseNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(logoutResponseNotificationKey)
        }
    }
    
    public func getEmailAvailability(email:String){
        var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/users/check_email_available")!)
        request.HTTPMethod = "POST"
        
        //preparo il body
        let postString = "{"
            + "\"email_to_check\": \"\(email)\""
            + "}"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        sendRequest(request, notification_key: mailAvailabilityResponseNotificationKey)
    }
    
    public func getUserInfo(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/users/\(userId)" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: userInfoResponseNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(userInfoResponseNotificationKey)
        }
    }
    
    public func getSettings(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/settings/" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getSettingsResponseNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getSettingsResponseNotificationKey)
        }
    }
    
    public func updateSettings(publishedEmail : Bool!, bookedEmail : Bool!, retractedEmail : Bool!, collectedEmail: Bool!, maxDistance: Int!){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/settings" + parameters)!)
            request.HTTPMethod = "POST"

            //preparo il body
            var postString = "{ \"notify_me_when\" : {  "
            postString += " \"published\": { "
            postString += " \"sms\": \"false\", "
            postString += " \"email\": \"\(publishedEmail)\" "
            postString += "},  "
            postString += " \"booked\": { "
            postString += " \"sms\": \"false\", "
            postString += " \"email\": \"\(bookedEmail)\" "
            postString += "},  "
            postString += " \"retracted\": { "
            postString += " \"sms\": \"false\", "
            postString += " \"email\": \"\(retractedEmail)\" "
            postString += "},  "
            postString += " \"collected\": { "
            postString += " \"sms\": \"false\", "
            postString += " \"email\": \"\(collectedEmail)\" "
            postString += "} },  "
            postString += " \"charity\" : {  "
            postString += " \"range\": \(maxDistance) "
            postString += "} }  "
            println(postString)
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            sendRequest(request, notification_key: settingsUpdatedNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(settingsUpdatedNotificationKey)
        }
    }
    
    //*********************************************************************************
    // NOTIFICATIONS
    //*********************************************************************************
    
    public func getNotifications(){
        if(isLoggedIn()){
            var parameters:String = "?user_credentials=\(singleAccessToken)"
            var request = NSMutableURLRequest(URL: NSURL(string: serverAddress + "/notifications" + parameters)!)
            request.HTTPMethod = "GET"
            sendRequest(request, notification_key: getNotificationsResponseNotificationKey)
        }
        else{
            ModelUpdater.getInstance().notifyNotLoggedInError(getNotificationsResponseNotificationKey)
        }
    }
    
    //*********************************************************************************
    // IMAGES
    //*********************************************************************************
    public func downloadImage(url:String, imDownloader: ImageDownloader!){
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        var task = self.imageSession.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            imDownloader.setImage(data, response: response, error: error)
            
        })
        
        task.resume()
    }
    
    private func clearImageCache(){
        self.imageCache.removeAllCachedResponses()
    }
    
    //*********************************************************************************
    // SEND REQUEST
    //*********************************************************************************
    
    private func sendRequest(request : NSMutableURLRequest, notification_key : String){
        
        //completo l'header
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token token=\"\(securityToken)\"", forHTTPHeaderField: "Authorization")
        
        //preparo il dialogo con il server
        var session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if(error == nil){
                
                let response_status = (response as! NSHTTPURLResponse).statusCode
                
                // attenzione: in swift, gli switch NON hanno
                // l'implicit fallthrough, e NON necessitano dei break
                switch response_status {
                case 200, 201, 204:
                    if self.cachedRequest(notification_key)! {
                        self.storeResponseInCache(notification_key, data: data)
                    }
                    ModelUpdater.getInstance().notifySuccess(notification_key, data: data, cachedResponse: false)
                case 400, 401, 403, 404, 409, 422: ModelUpdater.getInstance().notifyDataError(notification_key)
                default :
                    if self.cachedRequest(notification_key)! {
                        self.lookForResponseInCache(notification_key, networkStatus: RequestStatus.NETWORK_ERROR)
                    }
                    else {
                        ModelUpdater.getInstance().notifyNetworkError(notification_key)
                    }
                }
            }
            else{
                // error != nil
                if self.cachedRequest(notification_key)! {
                    self.lookForResponseInCache(notification_key, networkStatus: RequestStatus.DEVICE_ERROR)
                }
                else{
                    ModelUpdater.getInstance().notifyDeviceError(notification_key)
                }
            }
        })
        
        task.resume()
    }

    //*********************************************************************************
    // CACHING
    //*********************************************************************************
    
    private func storeResponseInCache(notificationKey:String!, data: NSData!){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(data, forKey: notificationKey)
    }
    
    private func lookForResponseInCache(notificationKey: String!, networkStatus: RequestStatus!){

        let defaults = NSUserDefaults.standardUserDefaults()
        let data : NSData? = defaults.objectForKey(notificationKey) as? NSData
        
        if data != nil {
            
            ModelUpdater.getInstance().notifySuccess(notificationKey, data: data!, cachedResponse: true)
            
        } else {
            if networkStatus == RequestStatus.DEVICE_ERROR {
                ModelUpdater.getInstance().notifyDeviceError(notificationKey)
            }
            else if networkStatus == RequestStatus.NETWORK_ERROR {
                ModelUpdater.getInstance().notifyNetworkError(notificationKey)
            }
        }
    }
    
    private func cachedRequest(notificationKey: String!) -> Bool! {
        if notificationKey == getMyDonationNotificationKey {
            return true
        }
        
        if notificationKey == getOthersDonationNotificationKey {
            return true
        }
    
        if notificationKey == getBookingsNotificationKey {
            return true
        }
        return false
    }
    
    
}
