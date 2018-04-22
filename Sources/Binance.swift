//
//  Binance.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Binance {
    
    public struct Account {
        public let makerCommission: NSDecimalNumber
        public let takerCommission: NSDecimalNumber
        public let buyerCommission: NSDecimalNumber
        public let sellerCommission: NSDecimalNumber
        public let canTrade: Bool
        public let canWithdraw: Bool
        public let canDeposit: Bool
        public let balances: [Balance]
        
        public init?(json: [String: Any], currencyStore: CurrencyStoreType) {
            makerCommission = NSDecimalNumber(json["makerCommission"])
            takerCommission = NSDecimalNumber(json["takerCommission"])
            buyerCommission = NSDecimalNumber(json["buyerCommission"])
            sellerCommission = NSDecimalNumber(json["sellerCommission"])
            canTrade = json["canTrade"] as? Bool ?? false
            canWithdraw = json["canWithdraw"] as? Bool ?? false
            canDeposit = json["canDeposit"] as? Bool ?? false
            if let balancesJSON = json["balances"] as? [[String: String]] {
                balances = balancesJSON.flatMap { Balance(json: $0, currencyStore: currencyStore) }
            } else {
                balances = []
            }
        }
        
        public class Balance: Cryptex.Balance {
            public var locked: NSDecimalNumber
            
            public init?(json: [String: String], currencyStore: CurrencyStoreType) {
                guard
                    let freeString = json["free"]
                    , let lockedString = json["locked"]
                    , freeString != "0.00000000" || lockedString != "0.00000000"
                    else { return nil }
                locked = NSDecimalNumber(string: lockedString)
                super.init(currency: currencyStore.forCode(json["asset"] ?? ""), quantity: NSDecimalNumber(string: freeString))
            }
        }
    }
    
    public class Store: ExchangeDataStore<Ticker, Account.Balance> {
        
        override fileprivate init() {
            super.init()
            name = "Binance"
            accountingCurrency = .USDT
        }
        
        public var tickersResponse: HTTPURLResponse? = nil
        public var accountResponse: (response: HTTPURLResponse?, account: Binance.Account?) = (nil, nil)
    }
    
    public enum API {
        case getAllPrices
        case account
    }
    
    public class Service: Network, TickerServiceType {
        
        public let store = Store()
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            let apiType = Binance.API.getAllPrices
            if apiType.checkInterval(response: store.tickersResponse) {
                completion(.cached)
            } else {
                binanceDataTaskFor(api: apiType, completion: { (response) in
                    guard
                        let tickerArray = response.json as? [[String: String]]
                        else {
                            print("Error: Cast Failed in \(#function)")
                            return
                    }
                    
                    var tickers: [Ticker] = []
                    for ticker in tickerArray {
                        let currencyPair = CurrencyPair(symbol: ticker["symbol"] ?? "", currencyStore: self)
                        let price = NSDecimalNumber(string: ticker["price"])
                        let ticker = Ticker(symbol: currencyPair, price: price)
                        tickers.append(ticker)
                    }
                    self.store.setTickersInDictionary(tickers: tickers)
                    self.store.tickersResponse = response.httpResponse
                    completion(.fetched)
                    
                }).resume()
            }
        }
        
        public func getAccount(completion: @escaping (ResponseType) -> Void) {
            let apiType = Binance.API.account
            if apiType.checkInterval(response: store.accountResponse.response) {
                completion(.cached)
            } else {
                binanceDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [String: Any] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    let account = Binance.Account(json: json, currencyStore: self)
                    if let balances = account?.balances {
                        self.store.balances = balances
                    }
                    self.store.accountResponse = (response.httpResponse, account)
                    completion(.fetched)
                    }.resume()
            }
        }
        
        func binanceDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                // Handle error here
                completion?(response)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if let key = key, let secret = secret, api.authenticated {
                
                var postData = api.postData
                postData["recvWindow"] = "5000"
                postData["timestamp"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
                
                if let hmac_sha = try? HMAC(key: secret, variant: .sha256).authenticate(Array(postData.queryString.utf8)) {
                    let signature = Data(bytes: hmac_sha).toHexString()
                    postData["signature"] = signature
                }
                
                var postDataString = ""
                if let data = postData.data, let string = data.string, postData.count > 0 {
                    
                    postDataString = string
                    
                    // POST payload
                    if case .POST = api.httpMethod {
                        mutableURLRequest.httpBody = data
                    } else if case .GET = api.httpMethod {
                        var urlString = mutableURLRequest.url?.absoluteString
                        urlString?.append("?")
                        urlString?.append(postData.queryString)
                        let url = URL(string: urlString!)
                        mutableURLRequest.url = url
                    }
                    
                    api.print("Request Data: \(postDataString)", content: .response)
                }
                mutableURLRequest.setValue(key, forHTTPHeaderField: "X-MBX-APIKEY")
            }
            
            return mutableURLRequest
        }
    }
}

extension Binance.API: APIType {
    public var host: String {
        return "https://api.binance.com/api"
    }
    
    public var path: String {
        switch self {
        case .getAllPrices: return "/v1/ticker/allPrices"
        case .account: return "/v3/account"
        }
    }
    
    public var httpMethod: HttpMethod {
        return .GET
    }
    
    public var authenticated: Bool {
        switch self {
        case .getAllPrices: return false
        case .account: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getAllPrices: return .url
        case .account: return .url
        }
    }
    
    public var postData: [String: String] {
        return [:]
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getAllPrices: return .aMinute
        case .account: return .aMinute
        }
    }
}

extension Binance.Service: BalanceServiceType {
    
    public func getBalances(completion: @escaping ( ResponseType) -> Void) {
        getTickers(completion: { (_) in
            self.getAccount(completion: { (response) in
                completion(response)
            })
        })
    }
}
