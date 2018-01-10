//
//  Network.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public protocol TickerServiceType {
    func getTickers(completion: @escaping (ResponseType) -> Void)
}

public protocol BalanceServiceType {
    func getBalances(completion: @escaping (ResponseType) -> Void)
}

open class Network {
    
    private let session: URLSession
    private var previousNonce: Int64 = 0
    private let nonceQueue = DispatchQueue(label: "com.sathyakumar.cryptex.network.nonce")
    public let userPreference: UserPreference
    
    public var isMock: Bool {
        return session is MockURLSession
    }
    
    public init(session: URLSession, userPreference: UserPreference) {
        self.session = session
        self.userPreference = userPreference
    }
    
    public func dataTaskFor(api: APIType, completion: ((Any, HTTPURLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
        let urlRequest = requestFor(api: api)
        api.print("\(urlRequest.httpMethod) \(urlRequest.url?.absoluteString ?? "")", content: .url)
        if LogLevel.requestHeaders.rawValue <= api.loggingEnabled.rawValue {
            urlRequest.printHeaders()
        }
        return session.dataTask(with: urlRequest as URLRequest) { (data, urlResponse, error) in
            
            if let error = error {
                api.print("Response Error: \(error)", content: .response)
            }
            
            let httpUrlResponse = urlResponse as? HTTPURLResponse
            api.print("\(httpUrlResponse?.statusCode ?? 0) \(httpUrlResponse?.url?.absoluteString ?? "")", content: .url)
            api.print("Response Headers: \(httpUrlResponse)", content: .responseHeaders)
            
            guard let data = data else {
                print("No Data for request: \(httpUrlResponse?.url?.absoluteString)")
                return
            }
            
            guard let responseDataString = data.string else { return }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("Data is not a json for request: \(httpUrlResponse?.url?.absoluteString)")
                //api.print(responseDataString, content: .response)
                completion?(responseDataString, httpUrlResponse, error)
                return
            }
            api.print("Response Data: \(responseDataString)", content: .response)
            
            completion?(json, httpUrlResponse, error)
        }
    }
    
    open func requestFor(api: APIType) -> NSMutableURLRequest {
        return api.mutableRequest
    }
    
    public func getTimestampInSeconds() -> Int64 {
        var ts: Int64 = 0
        nonceQueue.sync {
            let tsDecimal = NSDecimalNumber(value: Date().timeIntervalSince1970)
            ts = tsDecimal.timestampInSeconds
            if previousNonce == ts {
                let diff = 1.0 - tsDecimal.subtracting(NSDecimalNumber(value: ts)).doubleValue
                Thread.sleep(forTimeInterval: diff > 0 ? diff : 1)
                ts = NSDecimalNumber(value: Date().timeIntervalSince1970).timestampInSeconds
            }
        }
        previousNonce = ts
        return ts
    }
}

