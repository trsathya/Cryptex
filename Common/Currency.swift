//
//  Currency.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 12/30/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public protocol CurrencyType {
    var name: String { get }
    var code: String { get }
}

public struct Currency: CurrencyType, Hashable, Comparable {
    public let name: String
    public let code: String
    public let type: Category
    
    public init(name: String, code: String, type: Category) {
        self.name = name
        self.code = code
        self.type = type
    }
    
    public init(code: String) {
        self.init(name: code, code: code, type: .notDetermined)
    }
    
    public var hashValue: Int {
        get {
            return code.hashValue
        }
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
    
    public enum Category {
        case notDetermined
        case fiat
        case crypto
    }
}
