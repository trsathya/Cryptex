//
//  Enums.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/1/18.
//

import Foundation

public enum HttpMethod: String {
    case GET
    case POST
    case DELETE
    case PATCH
    case UPDATE
}

public enum LogLevel: UInt8 {
    case none = 0
    case url = 1
    case requestHeaders = 2
    case response = 3
    case responseHeaders = 4
}

public enum ResponseType {
    case fetched
    case cached
    case unexpected(Response)
}

public enum TransactionType: String {
    case none
    case buy
    case sell
    case withdraw
    case deposit
}

public enum TickerViewType: Int {
    case quantity = 0
    case price = 1
    case name = 2
}
