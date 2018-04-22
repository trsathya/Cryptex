//
//  API.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/1/18.
//

import Foundation

public protocol APIType {
    var host: String { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var authenticated: Bool { get }
    var loggingEnabled: LogLevel { get }
    var postData: [String: String] { get }
    var refetchInterval: TimeInterval { get }
}

public extension APIType {
    
    var mutableRequest: NSMutableURLRequest {
        let url = URL(string: host + path)!
        let mutableURLRequest = NSMutableURLRequest(url: url)
        mutableURLRequest.httpMethod = httpMethod.rawValue
        return mutableURLRequest
    }
    
    func checkInterval(response: HTTPURLResponse?) -> Bool {
        guard let response = response, let date = response.date, Date().timeIntervalSince(date) < refetchInterval else { return false }
        return true
    }
    
    func print(_ any: Any?, content: LogLevel) {
        guard let any = any, content.rawValue <= loggingEnabled.rawValue else { return }
        Swift.print(any)
    }
}
