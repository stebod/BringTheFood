//
//  Date.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 10/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class Date {
    
    private let date: NSDate!
    private let dateFormatter: NSDateFormatter!
    
    public init( dateString: String!){
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date =  self.dateFormatter.dateFromString(dateString)
    }
    
    public func getDateString() -> String!{
        
        return self.dateFormatter.stringFromDate(self.date)
    }
    
    public func getDate() -> NSDate! {
        return self.date
    }
    
}