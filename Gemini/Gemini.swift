//
//  Gemini.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public struct Gemini {
    public struct Ticker {
        public var bid: NSDecimalNumber
        public var ask: NSDecimalNumber
        public var last: NSDecimalNumber
        public var volume: Volume?
        
        public init?(json: Any?, for symbol: CurrencyPair) {
            guard let json = json as? [String: Any] else { return nil }
            
            bid = NSDecimalNumber(any: json["bid"])
            ask = NSDecimalNumber(any: json["ask"])
            last = NSDecimalNumber(any: json["last"])
            volume = Volume(json: json["volume"], for: symbol)
        }
        
        public struct Volume {
            public var timestamp: Date?
            public var price: String?
            public var quantity: String?
            
            public init?(json: Any?, for symbol: CurrencyPair) {
                guard let json = json as? [String: Any] else { return nil }
                price = json[symbol.price.code] as? String
                quantity = json[symbol.quantity.code] as? String
                if let time = json["timestamp"] as? Double {
                    timestamp = Date(timeIntervalSince1970: time/1000)
                } else {
                    timestamp = nil
                }
            }
        }
    }
}
