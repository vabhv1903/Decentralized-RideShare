//
//  RideViewControllerExt.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 3/16/21.
//

import Foundation
import PromiseKit
import Web3swift
import BigInt
import MapKit


/*
 Im not a huge fan of making extentions off view controllers,
 this help simplyfi what contract components are need within the app
 */

extension RideViewController {
    

    // MARK: updateAccountBalance
    // Updates bar button title with wallet Ether amount
    func updateAccountBalance() {
        firstly {
            getUserBalance()
        }.done { data in
            // Set bar button title to amount of ether
            self.balanceBarButton?.title = "\(data) ETH"
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    // MARK: getDriverState
    // Retrieves ride state for a driver address
    func getDriverState() {
        firstly {
            fetchDriverState()
        }.done { value in
            let address = value["rideID"]! as! EthereumAddress
            
            // check if we have a empty ride id
            // NOTE: Empty ride id == No or canceled ride
            if address.address != "0x0000000000000000000000000000000000000000" {
                rideID = address
            }
            // Get fether info about the ride
            self.getRideState(address: address)
        }
    }
    
    // MARK: getRideDriver
    // Checks if driver has a outstanding ride
    //
    // - DriverAddress      : EthereumAddress
    // - DriverVehicle      : String
    func getRideDriver(_ address: EthereumAddress?) {
        let searchAddress = address ?? EthereumAddress(wallet!.address)
        firstly {
            fetchRideState(address: searchAddress! , method: .fetchItemBufferTwo)
        }.done { response in
            let object = response as AnyObject
            let driverId = object["driverID"] as! EthereumAddress
            let driverVehicleDiscription = object["driverVehicleDiscription"] as AnyObject
            self.driverEther.text = "Driver Address: \(driverId.address)"
            self.driverVehicle.text = "Driver Info: \(driverVehicleDiscription)"
        }
    }
    
    // MARK: getRideState
    //
    // - RideState  : RideStates (Enum within ContractMethods)
    // - RidePrice  : BigInt
    // - RideDate   : Double (An epoch formated date)
    func getRideState(address:EthereumAddress) {

        firstly {
            fetchRideState(address: address,method: .fetchItemBufferThree)
        }.done { response in
            
            let stringStateValue = "\(response["rideState"]!)"
            let stringRidePrice = "\(response["ridePrice"]!)"
            let stringRideDate = "\(response["rideDate"]!)"
            
            let timeResult = Double(stringRideDate)
            
            let date = Date(timeIntervalSince1970: timeResult!)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            
            let localDate = dateFormatter.string(from: date)
            let price = BigInt(stringRidePrice)
            let amount = Web3.Utils.formatToEthereumUnits(price!, toUnits: .eth, decimals: 6)!
            
            let number = Int(stringStateValue)!
        
            rideState = getRideStatus(state:number)

            self.changeViewState(state: rideState)
            
            if rideState == .cancelRide {return}
            //self.userName.text = rideState.rawValue // User (Passenger) wallet address dosen't need to be shown
            self.ridePrice.text = "Price: \(amount) ETH"
            self.rideDate.text = "Date: \(localDate)"
            
            if stringRideDate != "0" && stringRidePrice != "0" {
                self.getRideDetails(address)
                self.getRideDriver(address)
            }
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: getRideDetails
    // Gets additional ride infomation
    //
    // - userName              : String
    // - pickUpAddress         : String
    // - dropOffAddress        : String
    // - userID                : EthereumAddress
    // - userVehicleRequestType: String
    
    func getRideDetails(_ address: EthereumAddress?) {
        let searchAddress = address ?? EthereumAddress(wallet!.address)
        firstly {
            fetchRideState(address: searchAddress! , method:.fetchItemBufferOne)
        }.done { response in
            
            // unwrape response varables
            let object = response as AnyObject
            let userName = object["passengerName"] as AnyObject
            let pickUpAddress = object["passengerPickUpAddress"] as AnyObject
            let pickUpString = "\(pickUpAddress)"
            let dropOffAddress = object["passengerDropOffAddress"] as AnyObject
            let dropOffString = "\(dropOffAddress)"
            // umm userId might not need to be use as its the ride ID
            let userId = object["userID"] as AnyObject
            let userVehicleRequestType = object["passengerVehicleRequestType"] as AnyObject
            
            // update views with ride info
            self.userName.text = "Name: \(userName)"
            self.vehicleType.text = "Vehicle: \(userVehicleRequestType)"
            self.pickUpAddress.text = "Pick Up: \(pickUpString)"
            self.dropOffAddress.text = "Drop Off: \(dropOffString)"
        
            if rideState != .driverConfirmsDropOff {
                // create annotations for pick up and drop off locations
                self.createAnnotation(address: pickUpString, title: "Pick Up")
                self.createAnnotation(address: dropOffString, title: "Drop Off")
            }
        }
    }
    
    // MARK: createSocket
    // Creates and opens a new connection listing for subscription events
    // Refer to delegate methods for incoming subscription events
    // NOTE: This should be made into a class
    func createSocket() -> InfuraWebsocketProvider {
        let newSocket = InfuraWebsocketProvider(contract!.socketURI!, delegate: self)
        newSocket!.connectSocket()
        
        let subscriptionRequest =
                    """
                            {"jsonrpc":"2.0", "id": 1, "method": "eth_subscribe", "params": ["logs", {"address": "\(contract!.contractAddress!.address)"}]}
                    """
        
        newSocket!.socket.onConnect = {
                self.wssSocket!.socket.write(string: subscriptionRequest)
        }
        return newSocket!
    }
    
    // Trying a ganache verison for socket subscriptions
    func createGanacheSocket() -> WebsocketProvider {
        
        // 
        let newSocket = WebsocketProvider(contract!.socketURI!, delegate: self, keystoreManager: contract!.keystoreManager, network: .Custom(networkID: 5777))
    
        
        newSocket!.connectSocket()
        
        let subscriptionRequest =
                    """
                            {"jsonrpc":"2.0", "id": 1, "method": "eth_subscribe", "params": ["logs", {"address": "\(contract!.contractAddress!.address)"}]}
                    """
        
        newSocket!.socket.onConnect = {
                self.ganacheSocket!.socket.write(string: subscriptionRequest)
        }
        return newSocket!
    }
    
}
