//
//  BookingsList.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 13/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

public class BookingsList: NSObject, UITableViewDataSource, UITableViewDelegate  {
    
    // Private variables
    private var donations: [DonationsList]! = []
    private var emptyTableView: UIView?
    private var mainMessageLabel: UILabel?
    private var secondaryMessageLabel: UILabel?
    private let textCellIdentifier = "TextCell"
    private var requestStatus: RequestStatus?
    var delegate: DisplayBookedDetail?
    
    
    // Initializer
    public init(currentBookingsList: [BookedDonation]!, historicBookingsList: [BookedDonation]!){
        var sortedCurrentBookingsList = currentBookingsList.sorted({(lhs: BookedDonation, rhs: BookedDonation) -> Bool in
            return lhs.getRemainingDays() < rhs.getRemainingDays()
        })
        var sortedHistoricBookingsList = historicBookingsList.sorted({(lhs: BookedDonation, rhs: BookedDonation) -> Bool in
            return lhs.getRemainingDays() < rhs.getRemainingDays()
        })
        donations.append(DonationsList(donationName: NSLocalizedString("PENDING_BOOKINGS",comment:"Pending bookings"), donationList: sortedCurrentBookingsList))
        donations.append(DonationsList(donationName: NSLocalizedString("COLLECTED_BOOKINGS",comment:"Collected bookings"), donationList: sortedHistoricBookingsList))
    }
    
    // Set number of section in table
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        emptyTableView = tableView.viewWithTag(999)
        if(!donations[0].donationsList.isEmpty || !donations[1].donationsList.isEmpty){
            if(emptyTableView != nil){
                emptyTableView?.hidden = true
            }
            return donations.count
        }
        if(emptyTableView == nil){
            createEmptyView(tableView)
        }
        if(requestStatus == RequestStatus.SUCCESS || requestStatus == RequestStatus.CACHE){
            mainMessageLabel?.text = NSLocalizedString("NO_DONATIONS",comment:"No donations")
            secondaryMessageLabel?.text = NSLocalizedString("PULL_DOWN",comment:"Pull down to refresh")
        }
        else{
            mainMessageLabel?.text = NSLocalizedString("NETWORK_ERROR",comment:"Network error")
            secondaryMessageLabel?.text = NSLocalizedString("CHECK_CONNECTIVITY_SHORT",comment:"Check your connectivity")
        }
        
        emptyTableView?.hidden = false
        
        return 0
    }
    
    // Set number of rows in each section
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let donationsInSection = donations[section]
        return donationsInSection.donationsList.count
    }
    
    // Build the cell
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let donationsInSection = donations[indexPath.section]
        let donation = donationsInSection.donationsList[indexPath.row]
        let mainLabel = cell.viewWithTag(1000) as! UILabel
        let addressLabel = cell.viewWithTag(1001) as! UILabel
        let expirationLabel = cell.viewWithTag(1002) as! UILabel
        let amountLabel = cell.viewWithTag(1004) as! UILabel
        let kgIcon = cell.viewWithTag(1005) as! UIImageView
        let ltIcon = cell.viewWithTag(1006) as! UIImageView
        let portionIcon = cell.viewWithTag(1007) as! UIImageView
        
        let description = donation.getDescription()
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
        
        let address = donation.getSupplier().getAddress().getLabel()
        first = address.startIndex
        rest = advance(first,1)..<address.endIndex
        addressLabel.text = address[first...first].uppercaseString + address[rest]
        
        if(donation.getRemainingDays() >= 0){
            expirationLabel.text = String(donation.getRemainingDays()) + NSLocalizedString("DAYS",comment:"d")
        }
        else{
            expirationLabel.text = NSLocalizedString("EXPIRED",comment:"Expired")
        }
        amountLabel.text = donation.getParcelSize() < Float(Int.max) ? "\(Int(donation.getParcelSize()))" : "\(Int.max)"
        let parcelUnit = donation.getParcelUnit()
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
        delegate?.displayDetail(donations[indexPath.section].donationsList[indexPath.row])
    }
    
    // Set section titles
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(requestStatus == RequestStatus.SUCCESS && donations[section].donationsList.count > 0){
            return donations[section].donationName
        }
        if(requestStatus == RequestStatus.CACHE && donations[section].donationsList.count > 0){
            return donations[section].donationName + " " + NSLocalizedString("OFFLINE_MODE",comment:"Offline mode")
        }
        return nil
    }
    
    // Set the status retrieved by rest interface for the current request
    func setRequestStatus(requestStatus: RequestStatus){
        self.requestStatus = requestStatus
    }

    // Display a message in case of empty table view
    func createEmptyView(tableView: UITableView){
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

private struct DonationsList {
    
    var donationsList : [BookedDonation]!
    var donationName: String
    
    init(donationName: String, donationList: [BookedDonation]!){
        self.donationName = donationName
        self.donationsList = donationList
    }
}