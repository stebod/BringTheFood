//
//  HTTPResponseData.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 05/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public class HTTPResponseData : AnyObject{
    
    public let status : RequestStatus!
    
    
    init(_ status: RequestStatus){
        self.status = status
    }
}

public enum RequestStatus {
    case NOT_LOGGED_IN, DEVICE_ERROR, NETWORK_ERROR, DATA_ERROR, SUCCESS
}