//
//  AddressCommunicator.swift
//  Bring the Food
//
//  Created by federico badini on 24/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

public protocol AddressCommunicator {
    func communicateAddress(address: String!)
    func triggerTableUpdate()
}