//
//  Protocols.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public protocol CurrencyStoreType {
    func isKnown(code: String) -> Bool
    func forCode(_ code: String) -> Currency
}


