//
//  Ticker.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/6/18.
//

import Foundation

public protocol TickerType: Comparable {
    var symbol: CurrencyPair { get }
    var price: NSDecimalNumber { get }
    var priceInUSD: NSDecimalNumber { get set }
    var priceInBTC: NSDecimalNumber { get set }
    var priceInETH: NSDecimalNumber { get set }
    var priceInLTC: NSDecimalNumber { get set }
    var priceInXRP: NSDecimalNumber { get set }
}

extension TickerType {
    
    public var formattedPriceInUSD: String {
        return NumberFormatter.usd.string(from: priceInUSD) ?? ""
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedAscending
    }
    
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedDescending
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedSame
    }
}

public class Ticker: TickerType, CustomStringConvertible {
    public let symbol: CurrencyPair
    public let price: NSDecimalNumber
    public var priceInUSD = NSDecimalNumber.zero
    public var priceInBTC = NSDecimalNumber.zero
    public var priceInETH = NSDecimalNumber.zero
    public var priceInLTC = NSDecimalNumber.zero
    public var priceInXRP = NSDecimalNumber.zero
    
    public init(symbol: CurrencyPair, price: NSDecimalNumber) {
        self.symbol = symbol
        self.price = price
    }
    
    public var description: String {
        return "\n" + symbol.displaySymbol + " : " + price.stringValue + " " + symbol.price.code
    }
}

public protocol DisplayableTickerType {
    var name: String { get }
    var price: String { get }
    var priceInUSD: String { get }
}

public struct DisplayableTicker: DisplayableTickerType {
    public var name: String
    public var price: String
    public var priceInUSD: String
}

public protocol TickerTableViewDataSource {
    func sectionCount(viewType: TickerViewType) -> Int
    func tickerCount(section: Int, viewType: TickerViewType) -> Int
    func sectionHeaderTitle(section: Int, viewType: TickerViewType) -> String?
    func displayableTicker(section: Int, row: Int, viewType: TickerViewType) -> DisplayableTickerType?
}

public protocol BalanceTableViewDataSource {
    func getTotalBalance() -> NSDecimalNumber
    func balanceCount() -> Int
    func displayableBalance(row: Int) -> DisplayableBalanceType
}
