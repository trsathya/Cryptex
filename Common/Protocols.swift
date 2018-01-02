//
//  Protocols.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public protocol CurrencyStoreType {
    static func isKnown(code: String) -> Bool
    static func forCode(_ code: String) -> Currency
}

public protocol ExchangeDataStoreType {
    var name: String { get }
}
