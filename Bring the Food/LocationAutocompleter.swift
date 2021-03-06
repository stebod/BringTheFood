//
//  LocationAutocompleter.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import GoogleMaps

public class LocationAutocompleter: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var resultList : [String]!
    private let textCellIdentifier = "TextCell"
    private let delegate: AddressCommunicator!
    
    public init(delegate: AddressCommunicator!) {
        self.resultList = [String]()
        self.delegate = delegate
    }
    
    
    public func retreiveCompleteAddress(searchText: String!){
        
        let placesClient = GMSPlacesClient()
        
        var data = [String]()
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (results, error) -> Void in
            
            if error != nil {
                return
            }
            
            if let predictions = results as? [GMSAutocompletePrediction]{
                for result in predictions {
                    data.append(result.attributedFullText.string)
                }
                
                self.resultList = data
            }
            else {
                return
            }
            
            self.delegate.triggerTableUpdate()
        })
    }
    
    // Set number of section in table
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    // Set number of rows in each section
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.resultList.count
    }
    
    // Build the cell
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = self.resultList[indexPath.row]
        
        return cell
    }
    
    // Handle click on tableView item
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate.communicateAddress(resultList[indexPath.row])
    }


}