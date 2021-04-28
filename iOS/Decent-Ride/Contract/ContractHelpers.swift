//
//  ContractHelpers.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 3/13/21.
//

import Foundation
import PromiseKit
import Web3swift
import BigInt

/**
 
 Calls contract method fetchDriverBuffer.  Should only be called from a driver address.
 
 - Note: Next step is to fetchRideState with rideId
 
 - returns: Promise wrapped Dictionary; ( rideid : address ) rideId assocaited with drivers address.
 
 */
func fetchDriverState() -> Promise<[String:Any]> {
    return Promise { seal in
        DispatchQueue.global().async {
            // Takes no parameters
            let rideStateParameters = [] as [AnyObject]
            do {
                let tx = contract!.buildCallMethod(method: "fetchDriverBuffer", parameters: rideStateParameters, wallet: wallet!)
                if tx != nil {
                    let value = try tx!.call()
                    seal.resolve(.fulfilled(value))
                }
            } catch {
                seal.reject(error)
            }
        }
    }
}

/**
 
 Calls contract method fetchRideState.
 
 - parameter address:   Passenger Address (RideId) associated with the ride
 - parameter method:    Contract method to be called
 
 - returns:  Promise wrapped Dictionary;  ( rideDate : uint256 ,ridePrice : uint , rideState : State )
 
 */
func fetchRideState(address:EthereumAddress,method:RideMethod) -> Promise<[String:Any]> {
    return Promise { seal in
        DispatchQueue.global().async {
            // Address (rideId) is the only parameter
            let rideStateParameters = [address] as [AnyObject]
            do{
                
                let tx = contract!.buildCallMethod(method: method.rawValue, parameters: rideStateParameters, wallet: wallet!)
                
                if tx != nil {
                    let value = try tx!.call()
                    seal.resolve(.fulfilled(value))
                }
                
            }catch {
                seal.reject(error)
            }
        }
    }
}

/**
 
 Calls web3's getBalance
 
 - returns  Promise wrapped String; amount of Ether for wallet address
 
 */
func getUserBalance() -> Promise<String> {
    return Promise { seal in
        DispatchQueue.global().async {
            do{
                // Make request for wallet balance
                let balance = try web3!.eth.getBalance(address: EthereumAddress(wallet!.address)!)
                // Format balance to Ether Units
                let amount = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 6)!
                // Resolve amount
                seal.resolve(.fulfilled(amount))
            }catch {
                // Reject error
                seal.reject(error)
            }
        }
    }
}

/**
 
 Writes to any contract method.
 
 - Note: Should be used when sending Ether or exchanging a asset; Requires wallet password
 
 - parameter method: Contract method to write to.
 - parameter amount: Amount of Ether to send.
 - parameter parameter: Parameters associated with contract method
 
 - returns Promise wrapped Bool
 
 */
func writeContractMethod(method:RideMethod,amount:BigUInt,parameters:[AnyObject]) -> Promise<Bool> {
    return Promise { seal in
        DispatchQueue.global().async {
            
            let tx = contract!.buildWriteMethod(method: method.rawValue, value: amount, parameters: parameters)
            do {
                let _ = try tx!.send(password: password!)
                seal.resolve(.fulfilled(true))
            }catch {
                seal.reject(error)
            }
        }
    }
}

/**
 
 Calls to any contract method.
    
 - Note: Requires wallet password Async
 
 - parameter method: Contract method to write to.
 - parameter parameter: Parameters associated with contract method
 
 - returns Promise wrapped Bool

 
 */
func callContractMethod(method:RideMethod,parameters:[AnyObject]) -> Promise<Bool> {
    return Promise { seal in
        DispatchQueue.global().async {
            
            let tx = contract!.buildCallMethod(method: method.rawValue, parameters: parameters,wallet: wallet!)
            do {
                let _ = try tx!.send(password: password!)
                seal.resolve(.fulfilled(true))
            }catch {
                seal.reject(error)
            }
        }
    }
}
