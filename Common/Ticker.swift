//
//  Ticker.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/6/18.
//

import Foundation

public protocol TickerType {
    var symbol: CurrencyPair { get }
    var price: NSDecimalNumber { get }
    var priceInUSD: NSDecimalNumber { get set }
}

public class Ticker: TickerType, Comparable {
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
