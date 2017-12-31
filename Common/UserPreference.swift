//
//  UserPreference.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public protocol UserPreference {
    var preferredFiatCurrency: Currency { get }
    var preferredCryptoCurrency: Currency { get }
    var ignoredFiatCurrencies: [Currency] { get }
}
