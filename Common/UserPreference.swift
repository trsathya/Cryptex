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
    public var currencyStore: CurrencyStoreType.Type
    
    public init(fiat: Currency, crypto: Currency, ignoredFiats: [Currency], currencyStore: CurrencyStoreType.Type) {
        self.fiat = fiat
        self.crypto = crypto
        self.ignoredFiats = ignoredFiats
        self.currencyStore = currencyStore
    }
}

