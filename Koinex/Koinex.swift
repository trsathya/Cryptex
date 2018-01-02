//
//  koinex.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 01/01/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import Foundation

public extension CurrencyPair {
    var koinexSymbol: String {
        return quantity.code
    }
}

public struct Koinex {
    public struct Ticker {
        public var symbol: CurrencyPair
        public var price: NSDecimalNumber
        
        public init(symbol: CurrencyPair, price: NSDecimalNumber) {
            self.symbol = symbol
            self.price = price
        }
    }
    
    public class Store: ExchangeDataStoreType {
        public static var shared = Store()
        
        public var name: String = "Koinex"
        
        private init() { }
        
        public var tickerResponse: (response: HTTPURLResponse?, tickers: [Koinex.Ticker]) = (nil, [])
    }
}


