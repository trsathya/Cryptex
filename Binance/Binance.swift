//
//  Binance.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public struct Binance {
    public struct Ticker: Comparable {
        public let symbol: CurrencyPair
        public let price: NSDecimalNumber
        public var priceInUSD = NSDecimalNumber.zero
        
        public init(symbol: CurrencyPair, price: NSDecimalNumber) {
            self.symbol = symbol
            self.price = price
        }
        
        public static func <(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedAscending
        }
        
        public static func >(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedDescending
        }
        
        public static func ==(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedSame
        }
    }
}
