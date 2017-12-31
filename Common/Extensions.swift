//
//  Extensions.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public extension NSDecimalNumber {
    public convenience init(any: Any?) {
        self.init(string: any as? String)
    }
}
