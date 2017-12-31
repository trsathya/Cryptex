//
//  Protocols.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public protocol CurrencyType {
    var name: String { get }
    var code: String { get }
}

public protocol CurrencyStoreType {
    static func isKnown(code: String) -> Bool
    static func forCode(_ code: String) -> Currency
}

public protocol ExchangeDataStoreType {
    var name: String { get }
    func getTotalBalance() -> NSDecimalNumber
}

public protocol UserPreferenceType {
    var preferredFiatCurrency: Currency { get }
    var preferredCryptoCurrency: Currency { get }
    var ignoredFiatCurrencies: [Currency] { get }
}

public protocol APIType {
    var host: String { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var authenticated: Bool { get }
    var loggingEnabled: LogLevel { get }
    var postData: [String: String] { get }
    var refetchInterval: TimeInterval { get }
}
