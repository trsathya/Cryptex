//
//  Balance.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/1/18.
//

import Foundation

public enum OrderType: String {
    case Buy = "Buy"
    case Sell = "Sell"
}

public protocol OrderProtocol {
    var type: OrderType? { get }
    var rate: NSDecimalNumber? { get }
}

open class Order: OrderProtocol {
    
    public var id: String?
    public var type: OrderType?
    public var rate: NSDecimalNumber?
    public var amount: NSDecimalNumber?
    public var remaining: NSDecimalNumber?
    public var total: NSDecimalNumber?
    public var market: CurrencyPair?
    
    init(json: [String: Any]) {
    }
}

public protocol BalanceType {
    var currency: Currency { get }
    var quantity: NSDecimalNumber { get }
}

public class Balance: BalanceType {
    public let currency: Currency
    public let quantity: NSDecimalNumber
    
    public init(currency: Currency, quantity: NSDecimalNumber) {
        self.currency = currency
        self.quantity = quantity
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
