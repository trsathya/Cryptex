//
//  CurrencyPair.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public struct CurrencyPair: Hashable, Comparable {
    
    public let quantity: Currency
    public let price: Currency
    
    public init(quantity: Currency, price: Currency) {
        self.quantity = quantity
        self.price = price
    }
    
    public init(symbol: String, currencyStore: CurrencyStoreType.Type) {
        let delimitterString = symbol.trimmingCharacters(in: .letters)
        if delimitterString.count == 1 {
            let currencySymbols = symbol.components(separatedBy: delimitterString)
            let quantity = currencyStore.forCode(currencySymbols[0])
            let price = currencyStore.forCode(currencySymbols[1])
            self.init(quantity: quantity, price: price)
        } else {
            var index = symbol.index(symbol.endIndex, offsetBy: -4)
            var priceCurrencyCode = String(symbol[index...])
            if currencyStore.isKnown(code: priceCurrencyCode) == false {
                index = symbol.index(index, offsetBy: 1)
                priceCurrencyCode = String(symbol[index...])
            }
            let price = currencyStore.forCode(priceCurrencyCode)
            let quantity = currencyStore.forCode(String(symbol[..<index]))
            self.init(quantity: quantity, price: price)
        }
    }
    
    public var displayName: String {
        let symbol = quantity.code + price.code
        return symbol.uppercased()
    }
    
    public var hashValue: Int {
        get {
            return quantity.hashValue ^ price.hashValue
        }
    }
    
    public static func <(lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        if lhs.quantity == rhs.quantity {
            return lhs.price < rhs.price
        } else {
            return lhs.quantity < rhs.quantity
        }
    }
    
    public static func ==(lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        return lhs.quantity == rhs.quantity && lhs.price == rhs.price
    }
}
