//
//  UserPreference.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/1/18.
//

import Foundation

public struct UserPreference {
    public var fiat: Currency
    public var crypto: Currency
    public var ignoredFiats: [Currency]
    //public var accounting: Accounting
    
    public init(fiat: Currency, crypto: Currency, ignoredFiats: [Currency]) {
        self.fiat = fiat
        self.crypto = crypto
        self.ignoredFiats = ignoredFiats
    }
    
    public static let USD_BTC = UserPreference(fiat: .USD, crypto: .Bitcoin, ignoredFiats: [])
    public static let USDT_BTC = UserPreference(fiat: .USDT, crypto: .Bitcoin, ignoredFiats: [])
}


