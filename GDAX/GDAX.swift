//
//  GDAX.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public struct GDAX {
    public struct Product {
        public var id: CurrencyPair
        public var baseCurrency: Currency
        public var quoteCurrency: Currency
        public var baseMinSize: NSDecimalNumber
        public var baseMaxSize: NSDecimalNumber
        public var quoteIncrement: NSDecimalNumber
        public var displayName: String
        public var marginEnabled: Bool
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType.Type) {
            self.id = CurrencyPair(symbol: json["id"] as! String, currencyStore: currencyStore)
            self.baseCurrency = currencyStore.forCode(json["base_currency"] as! String)
            self.quoteCurrency = currencyStore.forCode(json["quote_currency"] as! String)
            self.baseMinSize = NSDecimalNumber(any: json["base_min_size"])
            self.baseMaxSize = NSDecimalNumber(any: json["base_max_size"])
            self.quoteIncrement = NSDecimalNumber(any: json["quote_increment"])
            self.displayName = json["display_name"] as! String
            self.marginEnabled = json["margin_enabled"] as! Bool
        }
    }
    
    public struct Ticker {
        public let symbol: CurrencyPair
        public var tradeId: Int
        public var price: NSDecimalNumber
        public var size: NSDecimalNumber
        public var bid: NSDecimalNumber
        public var ask: NSDecimalNumber
        public var volume: NSDecimalNumber
        public var time: Date
        
        public init(json: [String: Any], symbol: CurrencyPair) {
            self.symbol = symbol
            self.tradeId = json["trade_id"] as? Int ?? 0
            self.price = NSDecimalNumber(any: json["price"])
            self.size = NSDecimalNumber(any: json["size"])
            self.bid = NSDecimalNumber(any: json["bid"])
            self.ask = NSDecimalNumber(any: json["ask"])
            self.volume = NSDecimalNumber(any: json["volume"])
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z" //"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let timeString = json["time"] as? String, let date = dateFormatter.date(from: timeString) {
                self.time = date
            } else {
                self.time = Date()
            }
        }
    }
}
