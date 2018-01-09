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
    public var currencyStore: CurrencyStoreType
    //public var accounting: Accounting
    
    public init(fiat: Currency, crypto: Currency, ignoredFiats: [Currency], currencyStore: CurrencyStoreType) {
        self.fiat = fiat
        self.crypto = crypto
        self.ignoredFiats = ignoredFiats
        self.currencyStore = currencyStore
    }
}

public struct Accounting<T: TickerType> {
    public var currencies: [Currency]
    public var tickers: [String: T]
    
    init(currencies: [Currency], tickers: [String: T]) {
        self.currencies = currencies
        self.tickers = tickers
    }
}
