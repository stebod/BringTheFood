//
//  MapsTest.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 20/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import XCTest
import GoogleMaps

class MapsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        GMSServices.provideAPIKey(gMapsAPIKey)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testAutoCompletion(){
        
        let doneExpectation = expectationWithDescription("done")
        
        let searchText = "via A.Vivaldi"
        let placesClient = GMSPlacesClient()
        
        var data = [String]()
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        
        if count(searchText) > 0 {
            println("Searching for '\(searchText)'")
            placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (results, error) -> Void in
                if error != nil {
                    XCTFail("Fail")
                    return
                }
                
                
                if let predictions = results as? [GMSAutocompletePrediction]{
                    for result in predictions {
                        data.append(result.attributedFullText.string)
                    }
                }
                else {
                    XCTFail("Fail")
                }
                
                for temp in data {
                    println(temp)
                }
                
                XCTAssert(true, "Pass")
                doneExpectation.fulfill()
            })
        } else {
            XCTFail("Fail")
        }
        
        self.waitForExpectationsWithTimeout(5, handler:{ error in
            XCTAssertNil(error, "Error")
        })
    }

}
