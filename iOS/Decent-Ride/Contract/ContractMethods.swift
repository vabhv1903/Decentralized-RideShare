//
//  contractMethods.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 2/11/21.
//

import Foundation


// Global contract enums

enum RideStates:String {
    case passengerRequestRide = "Passenger Request Ride"
    case driverAcceptsRide = "Driver Accepts Ride"
    case passengerConfirmsPickUp = "Passenger Confirms PickUp"
    case driverConfirmsDropOff = "Driver Confirms DropOff"
    case cancelRide = "Ride Canceled"
    case noActiveRide = "No Active Ride"
}

enum Role {
    case driver
    case passenger
}

enum Network {
    case rinkeby
    case ganache
}

enum Topics:String {
    case cancelRide = "0xce27f1037a1f16850157d2c9e7b76b9503e0cf3a70920a13b0921f6882d48069"
    case passengerRequestRide = "0x52d80ba20fc6a1a1d04897b91ee444bfe4a1b38ade3786ae0c7bf6c628b81006"
    case driverAccpetsRide = "0xbfe3587e86941a3cd5f57a8f13f6da9b2602985c9ed1a7c89bd7d4b7ff94f1d3"
    case passengerConfirmsPickUp = "0xd3f68a86f12223de49195853a339b891d585a44fccd13d8a2656a7194d6f6f67"
    case driverConfirmsDropOff = "0x5b64479ec7e33459a330d81aa877c0a9483e2c0b088fd439077f1b07ef5ed5b1"
}

enum RideMethod:String {
    case passengerRequestRide = "passengerRequestRide"
    case driverAcceptsRide = "driverAcceptsRide"
    case passengerConfirmsPickUp = "passengerConfirmsPickUp"
    case driverConfirmsDropOff = "driverConfirmsDropOff"
    case fetchitemHistory = "fetchitemHistory"
    case fetchItemBufferOne = "fetchRideItemBufferOne"
    case fetchItemBufferTwo = "fetchRideItemBufferTwo"
    case fetchItemBufferThree = "fetchRideItemBufferThree"
    case fetchDriverStates = "fetchDriverBuffer"
    case cancelRide = "cancelRide"
}



// MARK: getRideStatus
func getRideStatus(state: Int) -> RideStates {
    switch state {
    case 0:
        return RideStates.noActiveRide
        
    case 1:
        return RideStates.passengerRequestRide
        
    case 2:
        return RideStates.driverAcceptsRide
        
    case 3:
        return RideStates.passengerConfirmsPickUp
        
    case 4:
        return RideStates.driverConfirmsDropOff
    case 5:
        return RideStates.cancelRide
    default:
        return RideStates.noActiveRide
    }
}



