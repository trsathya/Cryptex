//
//  Balance.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/1/18.
//

import Foundation

public protocol BalanceType {
    var currency: Currency { get }
    var quantity: NSDecimalNumber { get }
}

public class Balance: BalanceType, CustomStringConvertible {
    public let currency: Currency
    public let quantity: NSDecimalNumber
    
    public init(currency: Currency, quantity: NSDecimalNumber) {
        self.currency = currency
        self.quantity = quantity
    }
    
    public var description: String {
        return currency.code + ": " + quantity.stringValue
    }
}

public protocol DisplayableBalanceType {
    var name: String { get }
    var balanceQuantity: String { get }
    var priceInUSD: String { get }
}

public struct DisplayableBalance: DisplayableBalanceType {
    public let name: String
    public let balanceQuantity: String
    public let priceInUSD: String
}
