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
    var priceInOtherCurencies: [Currency: NSDecimalNumber]? { get set }
    var accountingCurrency: Currency { get set }
}

extension TickerType {
    
    var name: String {
        return symbol.quantity.name
    }
    
    func price(in currency: Currency) -> NSDecimalNumber {
        return priceInOtherCurencies?[currency] ?? .zero
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.price(in: lhs.accountingCurrency).compare(rhs.price(in: rhs.accountingCurrency)) == .orderedAscending
    }
    
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.price(in: lhs.accountingCurrency).compare(rhs.price(in: rhs.accountingCurrency)) == .orderedDescending
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.price(in: lhs.accountingCurrency).compare(rhs.price(in: rhs.accountingCurrency)) == .orderedSame
    }
}

public class Ticker: TickerType, CustomStringConvertible {
    public let symbol: CurrencyPair
    public let price: NSDecimalNumber
    public var priceInOtherCurencies: [Currency: NSDecimalNumber]? = [:]
    public var accountingCurrency: Currency = .USD
    
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
    var formattedPriceInAccountingCurrency: String { get }
}

public struct DisplayableTicker: DisplayableTickerType {
    public var name: String
    public var price: String
    public var formattedPriceInAccountingCurrency: String
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
