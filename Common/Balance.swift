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

public struct Balance: BalanceType {
    public let currency: Currency
    public let quantity: NSDecimalNumber
    
    public init(currency: Currency, quantity: NSDecimalNumber) {
        self.currency = currency
        self.quantity = quantity
    }
}
