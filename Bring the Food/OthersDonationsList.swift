//
//  OthersDonationsList.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 13/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

public class OthersDonationsList: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // Private variables
    private var othersDonationsList: [OthersDonation]!
    private var othersDonationsFilteredList: [OthersDonation]!
    private var emptyTableView: UIView?
    private var mainMessageLabel: UILabel?
    private var secondaryMessageLabel: UILabel?
    private let textCellIdentifier = "TextCell"
    private var requestStatus: RequestStatus?
    var delegate: DisplayOthersDetail? 
    
    
    
    // Initializer
    public init(othersDonationsList: [OthersDonation]!){
        var sortedOthersDonationsList = othersDonationsList.sorted({(lhs: OthersDonation, rhs: OthersDonation) -> Bool in
            // you can have additional code here
            return lhs.getRemainingDays() < rhs.getRemainingDays()
        })
        self.othersDonationsList = sortedOthersDonationsList
        othersDonationsFilteredList = sortedOthersDonationsList
    }
    
    // Set number of section in table
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        emptyTableView = tableView.viewWithTag(999)
        if(othersDonationsFilteredList.count > 0){
            if(emptyTableView != nil){
                emptyTableView?.hidden = true
            }
            return 1
        }
        if(emptyTableView == nil){
            createEmptyView(tableView)
        }
        if(othersDonationsList.count == 0){
            if(requestStatus == RequestStatus.SUCCESS || requestStatus == RequestStatus.CACHE){
                mainMessageLabel?.text = NSLocalizedString("NO_DONATIONS",comment:"No donations")
                secondaryMessageLabel?.text = NSLocalizedString("PULL_DOWN",comment:"Pull down to refresh")
            }
            else{
                mainMessageLabel?.text = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
                secondaryMessageLabel?.text = NSLocalizedString("CHECK_CONNECTIVITY_SHORT",comment:"Check your connectivity")
            }
        }
        else{
            mainMessageLabel?.text = NSLocalizedString("NO_DONATIONS",comment:"No donations")
            secondaryMessageLabel?.text = NSLocalizedString("CHANGE_FILTERING_CRITERIA",comment:"Change filtering criteria")
        }
        emptyTableView?.hidden = false
            
        return 0
    }
    
    // Set number of rows in each section
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return othersDonationsFilteredList.count
    }
    
    // Build the cell
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        let mainLabel = cell.viewWithTag(1000) as! UILabel
        let addressLabel = cell.viewWithTag(1001) as! UILabel
        let expirationLabel = cell.viewWithTag(1002) as! UILabel
        let amountLabel = cell.viewWithTag(1004) as! UILabel
        let kgIcon = cell.viewWithTag(1005) as! UIImageView
        let ltIcon = cell.viewWithTag(1006) as! UIImageView
        let portionIcon = cell.viewWithTag(1007) as! UIImageView
        
        let description = othersDonationsFilteredList[row].getDescription()
        var first = description.startIndex
        var rest = advance(first,1)..<description.endIndex
        mainLabel.text = description[first...first].uppercaseString + description[rest]
        
        addressLabel.numberOfLines = 2
        let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
        if (iOS8) {
            // Do nothing, it will use automatic via the storyboard
        } else {
            let screenWidth = UIScreen.mainScreen().bounds.width
            addressLabel.preferredMaxLayoutWidth = screenWidth - 89;
        }
        
        let address = othersDonationsFilteredList[row].getSupplier().getAddress().getLabel()
        first = address.startIndex
        rest = advance(first,1)..<address.endIndex
        addressLabel.text = address[first...first].uppercaseString + address[rest]
        
        expirationLabel.text = String(othersDonationsFilteredList[row].getRemainingDays()) + NSLocalizedString("DAYS",comment:"d")
        amountLabel.text = othersDonationsFilteredList[row].getParcelSize() < Float(Int.max) ? "\(Int(othersDonationsFilteredList[row].getParcelSize()))" : "\(Int.max)"
        let parcelUnit = othersDonationsFilteredList[row].getParcelUnit()
        if(parcelUnit == ParcelUnit.KILOGRAMS){
            kgIcon.hidden = false
            ltIcon.hidden = true
            portionIcon.hidden = true
        }
        else if(parcelUnit == ParcelUnit.LITERS){
            kgIcon.hidden = true
            ltIcon.hidden = false
            portionIcon.hidden = true
        }
        else{
            kgIcon.hidden = true
            ltIcon.hidden = true
            portionIcon.hidden = false
        }
        
        return cell
    }
    
    // Handle click on tableView item
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.displayDetail(othersDonationsFilteredList[indexPath.row])
    }
    
    // Set section titles
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(requestStatus == RequestStatus.SUCCESS){
            return NSLocalizedString("AVAILABLE_DONATIONS",comment:"Available donations")
        }
        if(requestStatus == RequestStatus.CACHE){
            return NSLocalizedString("AVAILABLE_DONATIONS",comment:"Available donations") + " " + NSLocalizedString("OFFLINE_MODE",comment:"Offline mode")
        }
        return nil
    }
    
    // Set the filtering criteria
    func setFilter(filterState: FilterState){
        othersDonationsFilteredList.removeAll(keepCapacity: false)
        for donation in othersDonationsList{
            if(respectFilter(filterState, donation: donation)){
                othersDonationsFilteredList.append(donation)
            }
        }
    }
    
    // Check if each donation match the filtering criteria
    private func respectFilter(filterState: FilterState, donation: OthersDonation) -> Bool {
        if(donation.getProductType() == ProductType.FRESH && !filterState.isFreshFood){
            return false
        }
        if(donation.getProductType() == ProductType.COOKED && !filterState.isCookedFood){
            return false
        }
        if(donation.getProductType() == ProductType.DRIED && !filterState.isDriedFood){
            return false
        }
        if(donation.getProductType() == ProductType.FROZEN && !filterState.isFrozenFood){
            return false
        }
        if(donation.getRemainingDays() > filterState.expiration && filterState.expiration < 60){
            return false
        }
        return true
    }
    
    // Set the status retrieved by rest interface for the current request
    func setRequestStatus(requestStatus: RequestStatus){
        self.requestStatus = requestStatus
    }
    
    // Display a message in case of empty table view
    private func createEmptyView(tableView: UITableView){
        emptyTableView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height))
        mainMessageLabel = UILabel()
        mainMessageLabel!.textColor = UIColor.lightGrayColor()
        mainMessageLabel!.numberOfLines = 1
        mainMessageLabel!.textAlignment = .Center
        mainMessageLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        mainMessageLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        var widthConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        mainMessageLabel!.addConstraint(widthConstraint)
        var heightConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        mainMessageLabel!.addConstraint(heightConstraint)
        var xConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterX, multiplier: 1, constant: 0)
        var yConstraint = NSLayoutConstraint(item: mainMessageLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterY, multiplier: 1, constant: 0)
        emptyTableView!.addSubview(mainMessageLabel!)
        emptyTableView!.addConstraint(xConstraint)
        emptyTableView!.addConstraint(yConstraint)
        secondaryMessageLabel = UILabel()
        secondaryMessageLabel!.textColor = UIColor.lightGrayColor()
        secondaryMessageLabel!.numberOfLines = 1
        secondaryMessageLabel!.textAlignment = .Center
        secondaryMessageLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        secondaryMessageLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        widthConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        secondaryMessageLabel!.addConstraint(widthConstraint)
        heightConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        secondaryMessageLabel!.addConstraint(heightConstraint)
        xConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: emptyTableView, attribute: .CenterX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: secondaryMessageLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: mainMessageLabel, attribute: .CenterY, multiplier: 1, constant: 30)
        emptyTableView!.addSubview(secondaryMessageLabel!)
        emptyTableView!.addConstraint(xConstraint)
        emptyTableView!.addConstraint(yConstraint)
        emptyTableView?.tag = 999
        tableView.addSubview(emptyTableView!)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
}