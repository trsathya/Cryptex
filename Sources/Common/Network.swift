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

public struct Response {
    let data: Data?
    let httpResponse: HTTPURLResponse?
    let error: Error?
    var json: Any?
    var string: String?
    
    init(data: Data?, httpResponse: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.httpResponse = httpResponse
        self.error = error
    }
}

open class Network {
    
    let key: String?
    let secret: String?
    private let session: URLSession
    private var previousNonce: Int64 = 0
    private let nonceQueue = DispatchQueue(label: "com.sathyakumar.cryptex.network.nonce")
    public let userPreference: UserPreference
    var currencyOverrides: [String: Currency]?
    var apiCurrencyOverrides: [String: Currency]?
    
    public var isMock: Bool {
        return session is MockURLSession
    }
    
    public init(key: String?, secret: String?, session: URLSession, userPreference: UserPreference, currencyOverrides: [String: Currency]?) {
        self.key = key
        self.secret = secret
        self.session = session
        self.userPreference = userPreference
        self.currencyOverrides = currencyOverrides
    }
    
    public func dataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
        let urlRequest = requestFor(api: api)
        api.print("\(urlRequest.httpMethod) \(urlRequest.url?.absoluteString ?? "")", content: .url)
        if LogLevel.requestHeaders.rawValue <= api.loggingEnabled.rawValue {
            urlRequest.printHeaders()
        }
        return session.dataTask(with: urlRequest as URLRequest) { (data, urlResponse, error) in
            var response = Response(data: data, httpResponse: urlResponse as? HTTPURLResponse, error: error)
            response.string = data?.string
            if let data = data {
                response.json = try? JSONSerialization.jsonObject(with: data, options: [])
            }
            api.print("\(response.httpResponse?.description ?? "")", content: .url)
            api.print("Response Headers: \(String(describing: response.httpResponse))", content: .responseHeaders)
            api.print("Response Data: \(response.string ?? "")", content: .response)
            completion?(response)
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

extension Network: CurrencyStoreType {
    public func isKnown(code: String) -> Bool {
        let uppercased = code.uppercased()
        if let overrides = apiCurrencyOverrides, let _ = overrides[uppercased] {
            return true
        } else if let overrides = currencyOverrides, let _ = overrides[uppercased] {
            return true
        } else if let _ = Currency.currencyLookupDictionary[uppercased] {
            return true
        } else {
            return false
        }
    }
    
    public func forCode(_ code: String) -> Currency {
        let uppercased = code.uppercased()
        if let overrides = apiCurrencyOverrides, let currency = overrides[uppercased] {
            return currency
        } else if let overrides = currencyOverrides, let currency = overrides[uppercased] {
            return currency
        } else if let currency = Currency.currencyLookupDictionary[uppercased] {
            return currency
        } else {
            return Currency(code: code)
        }
    }
}

