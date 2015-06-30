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

/// Enum describing the possible outcomes of a rest request
public enum RequestStatus {
    
    /// The user is not logged in the system, so 
    /// the server is not allowed to handle the request
    case NOT_LOGGED_IN
    
    /// The device in use is not connected
    /// to the Internet
    case DEVICE_ERROR
    
    /// The request did not reach the server, or the 
    /// server crashed
    case NETWORK_ERROR
    
    /// The server received correctly the request, but 
    /// the data contained in the request did not make
    /// sense, or the user does not have permissions to
    /// perform the requested operation
    case DATA_ERROR
    
    /// Data was correctly received and handled by the server
    case SUCCESS
    
    /// The device was not able to communicate with the server,
    /// but the same request has already been sent before, so 
    /// the model is updated according to the cached data
    case CACHE
}