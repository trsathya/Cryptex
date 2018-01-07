//
//  Currency.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/30/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public class Currency: Hashable, Comparable {
    public let name: String
    public let code: String
    
    public init(name: String, code: String) {
        self.name = name
        self.code = code
    }

    public var hashValue: Int {
        return code.hashValue
    }
    
    public static func <(lhs: Currency, rhs: Currency) -> Bool {
        if lhs.name == rhs.name {
            return lhs.code < rhs.code
        } else {
            return lhs.name < rhs.name
        }
    }
    
    public static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code.lowercased() == rhs.code.lowercased()
    }
}

public extension Currency {
    
    public convenience init(code: String) {
        self.init(name: code, code: code)
    }
    
    static let USD = Currency(name: "US Dollar", code: "USD")
    static let Bitcoin = Currency(name: "Bitcoin", code: "BTC")
    static let Ethereum = Currency(name: "Ethereum", code: "ETH")
    static let Litecoin = Currency(name: "Litecoin", code: "LTC")
    static let Ripple = Currency(name: "Ripple", code: "XRP")
    static let Cardano = Currency(name: "Cardano", code: "ADA")
    static let NEM = Currency(name: "NEM", code: "XEM")
    static let USDT = Currency(name: "Tether USD", code: "USDT")
    static let currencies: [Currency] = [
        USD,
        Bitcoin,
        Ethereum,
        Ripple,
        Litecoin,
        Cardano,
        NEM,
        USDT
        ]
}
