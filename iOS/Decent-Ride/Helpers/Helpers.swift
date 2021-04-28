//
//  helpers.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 3/13/21.
//

import Foundation
import Web3swift

func checkRideId(address:EthereumAddress) -> Bool {
    if address == rideID {
        return true
    }else{
        return false
    }
}
