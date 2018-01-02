//
//  Cryptopia.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/2/18.
//

import Foundation

public struct Cryptopia {
    
    
    public enum API {
        case getMarkets
        case getBalance
    }
}

extension Cryptopia.API: APIType {
    public var host: String {
        return "https://www.cryptopia.co.nz/api"
    }
    
    public var path: String {
        switch self {
        case .getMarkets: return "/GetMarkets"
        case .getBalance: return "/GetBalance"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .getMarkets: return .GET
        case .getBalance: return .POST
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .getMarkets: return false
        case .getBalance: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getMarkets: return .responseHeaders
        case .getBalance: return .responseHeaders
        }
    }
    
    public var postData: [String : String] {
        switch self {
        case .getMarkets: return [:]
        case .getBalance: return [:]
        }
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getMarkets: return .aMinute
        case .getBalance: return .aMinute
        }
    }
    
    
}
