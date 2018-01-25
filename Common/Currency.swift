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
    
    static let USD = Currency(name: "United States dollar", code: "USD")
    static let EUR = Currency(name: "Euro", code: "EUR")
    static let JPY = Currency(name: "Japanese yen", code: "JPY")
    static let GBP = Currency(name: "Pound sterling", code: "GBP")
    static let AUD = Currency(name: "Australian dollar", code: "AUD")
    static let CAD = Currency(name: "Canadian dollar", code: "CAD")
    static let CHF = Currency(name: "Swiss franc", code: "CHF")
    static let CNY = Currency(name: "Renminbi", code: "CNY")
    static let SEK = Currency(name: "Swedish krona", code: "SEK")
    static let NZD = Currency(name: "New Zealand dollar", code: "NZD")
    static let MXN = Currency(name: "Mexican peso", code: "MXN")
    static let SGD = Currency(name: "Singapore dollar", code: "SGD")
    static let HKD = Currency(name: "Hong Kong dollar", code: "HKD")
    static let NOK = Currency(name: "Norwegian krone", code: "NOK")
    static let KRW = Currency(name: "South Korean won", code: "KRW")
    static let TRY = Currency(name: "Turkish lira", code: "TRY")
    static let RUB = Currency(name: "Russian ruble", code: "RUB")
    static let INR = Currency(name: "Indian rupee", code: "INR")
    static let BRL = Currency(name: "Brazilian real", code: "BRL")
    static let ZAR = Currency(name: "South African rand", code: "ZAR")
    static let Bitcoin = Currency(name: "Bitcoin", code: "BTC")
    static let Ethereum = Currency(name: "Ethereum", code: "ETH")
    static let Litecoin = Currency(name: "Litecoin", code: "LTC")
    static let Ripple = Currency(name: "Ripple", code: "XRP")
    static let Cardano = Currency(name: "Cardano", code: "ADA")
    static let NEM = Currency(name: "NEM", code: "XEM")
    static let USDT = Currency(name: "Tether USD", code: "USDT")
    static let ETC = Currency(name: "Ethereum Classic", code: "ETC")
    static let BCH = Currency(name: "Bitcoin Cash", code: "BCH")
    static let DOGE = Currency(name: "Dogecoin", code: "DOGE")
    static let XMR = Currency(name: "Monero", code: "XMR")
    static let ZEC = Currency(name: "Zcash", code: "ZEC")
    static let DASH = Currency(name: "Dash", code: "DASH")
    
    static let currencies: [Currency] = [
        USD, EUR, JPY, GBP, AUD, CAD, CHF, CNY, SEK, NZD, MXN, SGD, HKD, NOK, KRW, TRY, RUB, INR, BRL, ZAR,
        Bitcoin,
        Ethereum,
        Ripple,
        Litecoin,
        Cardano,
        NEM,
        USDT,
        ETC,
        BCH,
        DOGE,
        XMR,
        ZEC,
        DASH
    ]
}
