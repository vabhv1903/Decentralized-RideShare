//
//  dataStructs.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 4/22/21.
//

import Foundation

/**
 Ganache
 {"jsonrpc":"2.0",
 "method":"eth_subscription",
 "params":{
    "subscription":"0xf",
    "result"      {
            "logIndex":"0x0",
            "transactionIndex":"0x0",
            "transactionHash":"0x349257ca22c59cb5a5cac280a00ddd8484d378ac26e5804bd1210e5ad6aff640",
            "blockHash":"0x13216b522c1a2b5e8e603971636a67ccb754a2257234af8175eb3b9791595484",
            "blockNumber":"0xb",
            "address":"0x829810f61724422124ce910fae3d635b6b32057a",
            "data":"0x000000000000000000000000fbc0c9383f91d54539d7cf5db2c0fa5fd31f5372",
            "topics":["0x52d80ba20fc6a1a1d04897b91ee444bfe4a1b38ade3786ae0c7bf6c628b81006"],
            "type":"mined",
            "removed":false
            }
        }
 }
 
 Infura
 {"jsonrpc":"2.0",
 "method":"eth_subscription",
 "params":{
    "subscription":"0x1feed34018481882b3b1150fd179c49",
    "result":   {
            "removed":false,
            "logIndex":"0xc",
            "transactionIndex":"0x5",
            "transactionHash":"0xc80d987f0153293a94a3cadbc3aec62abff4949c9293ffd3faaf5ebcd2f445cc",
            "blockHash":"0x91700fe52292e582cf468b96bcc613aaedd86347d8def039af19eda37c0f4e52",
            "blockNumber":"0x8118de",
            "address":"0x1378FB98708C9003ee44D9ECf787b7da1d5CaC7F",
            "data":"0x000000000000000000000000894871b58cb4967c8a17c6ac40033b8aa2249e78",
            "topics":["0xce27f1037a1f16850157d2c9e7b76b9503e0cf3a70920a13b0921f6882d48069"]
 
            }
        }
    }
 {"jsonrpc":"2.0","method":"eth_subscription","params":{"subscription":"0x9","result":{"logIndex":"0x0","transactionIndex":"0x0","transactionHash":"0x838033063a430a638b9b3db06913f61b0c4131e5037cc8073886cef98eecb6a2","blockHash":"0xea6c1f18b8de2f3477f74b31dd8a050c5a2d47464f68b8f190f6fefaac1641c5","blockNumber":"0x7","address":"0xbc4cd339ea5ecb594c8005c392083df0d5941087","data":"0x000000000000000000000000c342acdb6061a31b6b081164925a1fda8054814f","topics":["0xce27f1037a1f16850157d2c9e7b76b9503e0cf3a70920a13b0921f6882d48069"],"type":"mined"}}}

 */

struct SubscribtionResult : Decodable {
    let logIndex:String?
    let transactionIndex: String?
    let transactionHash:String?
    let blockHash:String?
    let blockNumber:String?
    let address:String?
    let data: String?
    let topics: [String]
    let type: String?
    let removed: Bool?
}

struct SubscribtionParams: Decodable{
    let subscription:String?
    let result: SubscribtionResult
}

struct SubscriptionLog: Decodable {
    let jsonrpc:String?
    let method:String?
    let params:SubscribtionParams
}

struct SubscribtionMeta: Decodable{
    let id:Int?
    let jsonrpc:String?
    let result:String?
}
