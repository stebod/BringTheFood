//
//  RestTest.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 09/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit
import XCTest
import Bring_the_Food

class RestTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

  /*  func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/

    //*********************************************************************************
    // UESR CALLS TESTS
    //*********************************************************************************
   
    
    
    func testMailAvailable(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(mailAvailabilityResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().getEmailAvailability("badini.stefano@gmail.com")
        self.waitForExpectationsWithTimeout(5, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testMailNotAvailable(){
      
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(mailAvailabilityResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status != RequestStatus.SUCCESS){
                   
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().getEmailAvailability("bodini.stefano@gmail.com")
        self.waitForExpectationsWithTimeout(5, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testLogin(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@icloud.com",
            password: "ciao")
        self.waitForExpectationsWithTimeout(5, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }
    
    
    
    func testLogout(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(logoutResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    RestInterface.getInstance().logout()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(5, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }

    
    func testGetUserInfo(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(userInfoResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                
                    Model.getInstance().downloadCurrentUser()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }
    
    
    func testGetUserSettings(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(getSettingsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    Model.getInstance().downloadMySettings()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }
    
    
    
    
    //*********************************************************************************
    // DONATION CALLS TESTS
    //*********************************************************************************
   
    /*
    
    func testCreateDonation(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(donationCreatedNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    var data = response!.data
                    println(toString(data))
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    let donation = NewDonation("test donation", parcelSize: 7, parcelUnit: ParcelUnit.KILOGRAMS,
                        productDate: Date(dateString: "2017-08-23"), productType: ProductType.FROZEN, photo: nil)
                    RestInterface.getInstance().createDonation(donation)
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
    func testDeleteDonation(){
        
        let doneExpectation = expectationWithDescription("done")

        NSNotificationCenter.defaultCenter().addObserverForName(donationDeletedNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    var data = response!.data
                    println(toString(data))
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(donationCreatedNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    var data = response!.data
                    var idToDelete = (data![0]["donation"] as! NSDictionary)["id"] as! Int
                    println(idToDelete)
                    RestInterface.getInstance().deleteDonation(idToDelete)
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    let donation = NewDonation("test donation", parcelSize: 7, parcelUnit: ParcelUnit.KILOGRAMS,
                        productDate: Date(dateString: "2017-08-23"), productType: ProductType.FROZEN, photo: nil)
                    RestInterface.getInstance().createDonation(donation)
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
    func testgetOthersDonation(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(getOthersDonationNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    var data = response!.data
                    println(toString(data))
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: RestInterface.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    RestInterface.getInstance().getOthersDonations()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
    */
    
    func testgetMyDonation(){
        
        let doneExpectation = expectationWithDescription("done")
        
        NSNotificationCenter.defaultCenter().addObserverForName(getMyDonationNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    // controllare che i dati ci siano
                    
                    
                    XCTAssert(true, "Pass")
                    doneExpectation.fulfill()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(loginResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in
                let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
                if(response!.status == RequestStatus.SUCCESS){
                    
                    Model.getInstance().downloadMyDonationsList()
                }
                else{
                    XCTFail("Fail")
                }
        })
        
        RestInterface.getInstance().sendLoginData("bodini.stefano@gmail.com",
            password: "fedeealesonoalmiofianco")
        self.waitForExpectationsWithTimeout(10, handler:{ error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
}
