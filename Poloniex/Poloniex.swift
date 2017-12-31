//
//  Poloniex.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public struct Poloniex {
    public struct Ticker: Comparable {
        public let symbol: CurrencyPair
        public let timestamp: Date
        
        public var id: Int?
        public var last = NSDecimalNumber.zero
        public var lastInUSD = NSDecimalNumber.zero
        public var highestBid = NSDecimalNumber.zero
        public var lowestAsk = NSDecimalNumber.zero
        public var high24hr = NSDecimalNumber.zero
        public var low24hr = NSDecimalNumber.zero
        public var percentChange = NSDecimalNumber.zero
        public var quoteVolume = NSDecimalNumber.zero
        public var baseVolume = NSDecimalNumber.zero
        public var isFrozen: Bool?
        
        public init?(json: Any?, symbol: CurrencyPair, timestamp: Date) {
            self.symbol = symbol
            self.timestamp = timestamp
            guard let json = json as? [String: Any] else { return nil }
            id = json["id"] as? Int
            last = NSDecimalNumber(any: json["last"])
            highestBid = NSDecimalNumber(any: json["highestBid"])
            lowestAsk = NSDecimalNumber(any: json["lowestAsk"])
            high24hr = NSDecimalNumber(any: json["high24hr"])
            low24hr = NSDecimalNumber(any: json["low24hr"])
            percentChange = NSDecimalNumber(any: json["percentChange"])
            quoteVolume = NSDecimalNumber(any: json["quoteVolume"])
            baseVolume = NSDecimalNumber(any: json["baseVolume"])
            isFrozen = json["isFrozen"] as? Bool
        }
        
        public static func <(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.lastInUSD.compare(rhs.lastInUSD) == .orderedAscending
        }
        
        public static func >(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.lastInUSD.compare(rhs.lastInUSD) == .orderedDescending
        }
        
        public static func ==(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.lastInUSD.compare(rhs.lastInUSD) == .orderedSame
        }
    }
}
