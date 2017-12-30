//
//  Currency.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 12/30/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

struct Currency: Hashable, Comparable {
    let name: String
    let code: String
    let type: Category
    
    var hashValue: Int {
        get {
            return code.hashValue
        }
    }
    
    static func <(lhs: Currency, rhs: Currency) -> Bool {
        if lhs.name == rhs.name {
            return lhs.code < rhs.code
        } else {
            return lhs.name < rhs.name
        }
    }
    
    static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code.lowercased() == rhs.code.lowercased()
    }
    
    enum Category {
        case notDetermined
        case fiat
        case crypto
    }
}
