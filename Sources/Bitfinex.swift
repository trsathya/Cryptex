//
//  Bitfinex.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Bitfinex {
    
    public class Ticker: Cryptex.Ticker {
        public let mid: NSDecimalNumber
        public let bid: NSDecimalNumber
        public let ask: NSDecimalNumber
        public let lastPrice: NSDecimalNumber
        public let low: NSDecimalNumber
        public let high: NSDecimalNumber
        public let volume: NSDecimalNumber
        public let timestamp: NSDecimalNumber
        
        public init(json: [String: String], for symbol: CurrencyPair) {
            mid = NSDecimalNumber(json["mid"])
            bid = NSDecimalNumber(json["bid"])
            ask = NSDecimalNumber(json["ask"])
            lastPrice = NSDecimalNumber(json["last_price"])
            low = NSDecimalNumber(json["low"])
            high = NSDecimalNumber(json["high"])
            volume = NSDecimalNumber(json["volume"])
            timestamp = NSDecimalNumber(json["timestamp"])
            super.init(symbol: symbol, price: lastPrice)
        }
    }
    
    public class Balance: Cryptex.Balance {
        
        public let type: String
        public let amount: NSDecimalNumber
        public let available: NSDecimalNumber
        
        public init(json: [String: String], currencyStore: CurrencyStoreType) {
            type = json["type"] ?? ""
            amount = NSDecimalNumber(json["amount"])
            available = NSDecimalNumber(json["available"])
            super.init(currency: currencyStore.forCode(json["currency"] ?? ""), quantity: available)
        }
    }
    
    public class Store: ExchangeDataStore<Ticker, Balance> {
        
        override fileprivate init() {
            super.init()
            name = "Bitfinex"
            accountingCurrency = .USD
        }
        
        public var symbolsResponse: (response: HTTPURLResponse?, symbols: [CurrencyPair]) = (nil, [])
        public var tickerResponse: [String: HTTPURLResponse] = [:]
        public var balanceResponse: HTTPURLResponse? = nil
        public var accountFeesResponse: HTTPURLResponse? = nil
    }
    
    public enum API {
        case symbols
        case ticker(String)
        case balances
    }
    
    public class Service: Network {
        
        public let store = Store()
        
        public func getSymbols(completion: @escaping (ResponseType) -> Void) {
            let apiType = Bitfinex.API.symbols
            if apiType.checkInterval(response: store.symbolsResponse.response) {
                completion(.cached)
            } else {
                bitfinexDataTaskFor(api: apiType, completion: { (response) in
                    guard let stringArray = response.json as? [String] else {
                        completion(.unexpected(response))
                        return
                    }
                    let geminiSymbols = stringArray.flatMap { CurrencyPair(symbol: $0, currencyStore: self) }
                    self.store.symbolsResponse = (response.httpResponse, geminiSymbols)
                    completion(.fetched)
                }).resume()
            }
        }
        
        public func getTicker(symbol: CurrencyPair, completion: @escaping (CurrencyPair, ResponseType) -> Void) {
            let apiType = Bitfinex.API.ticker(symbol.displaySymbol)
            if apiType.checkInterval(response: store.tickerResponse[symbol.displaySymbol]) {
                completion(symbol, .cached)
            } else {
                bitfinexDataTaskFor(api: apiType, completion: { (response) in
                    guard let json = response.json as? [String: String] else {
                        completion(symbol, .unexpected(response))
                        return
                    }
                    self.store.setTicker(ticker: Ticker(json: json, for: symbol), symbol: symbol.displaySymbol)
                    self.store.tickerResponse[symbol.displaySymbol] = response.httpResponse
                    completion(symbol, .fetched)
                }).resume()
            }
        }
        
        public func getAccountBalances(completion: @escaping (ResponseType) -> Void) {
            let apiType = Bitfinex.API.balances
            if apiType.checkInterval(response: store.balanceResponse) {
                completion(.cached)
            } else {
                bitfinexDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [[String: String]] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    var balances: [Balance] = []
                    json.forEach({ (dictionary) in
                        balances.append(Balance(json: dictionary, currencyStore: self))
                    })
                    self.store.balances = balances
                    self.store.balanceResponse = response.httpResponse
                    completion(.fetched)
                    }.resume()
            }
        }
        
        private func bitfinexDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                // Handle error here
                completion?(response)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if let key = key, let secret = secret, api.authenticated {
                
                var postDataDictionary = api.postData
                postDataDictionary["request"] = api.path
                postDataDictionary["nonce"] = "\(getTimestampInSeconds())" // String nonce
                
                var postDataString = ""
                if let data = postDataDictionary.data {
                    postDataString = data.base64EncodedString()
                }
                
                mutableURLRequest.setValue(postDataString, forHTTPHeaderField: "X-BFX-PAYLOAD")
                
                do {
                    let hmac_sha = try HMAC(key: secret, variant: .sha384).authenticate(Array(postDataString.utf8))
                    mutableURLRequest.setValue(hmac_sha.toHexString(), forHTTPHeaderField: "X-BFX-SIGNATURE")
                } catch {
                    print(error)
                }
                mutableURLRequest.setValue(key, forHTTPHeaderField: "X-BFX-APIKEY")
            }
            
            return mutableURLRequest
        }
    }
}

extension Bitfinex.API: APIType {
    public var host: String {
        return "https://api.bitfinex.com"
    }
    
    public var path: String {
        switch self {
        case .symbols: return "/v1/symbols"
        case .ticker(let symbol): return "/v1/pubticker/\(symbol)"
        case .balances: return "/v1/balances"
        }
    }
    
    public var httpMethod: HttpMethod {
        return .GET
    }
    
    public var authenticated: Bool {
        switch self {
        case .symbols: return false
        case .ticker: return false
        case .balances: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .symbols: return .url
        case .ticker: return .url
        case .balances: return .url
        }
    }
    
    public var postData: [String: String] {
        return [:]
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .symbols: return .aMonth
        case .ticker: return .aMinute
        case .balances: return .aMinute
        }
    }
}

extension Bitfinex.Service: TickerServiceType, BalanceServiceType {
    
    public func getTickers(completion: @escaping ( ResponseType) -> Void) {
        getSymbols(completion: { _ in
            
            var tasks: [String: Bool] = [:]
            
            self.store.symbolsResponse.symbols.forEach { symbol in
                tasks[symbol.displaySymbol] = false
            }
            
            self.store.symbolsResponse.symbols.forEach { symbol in
                self.getTicker(symbol: symbol, completion: { (currencyPair, responseType) in
                    tasks[currencyPair.displaySymbol] = true
                    
                    let flag = tasks.values.reduce(true, { (result, value) -> Bool in
                        return result && value
                    })
                    if flag {
                        completion(responseType)
                    }
                })
            }
        })
    }
    
    public func getBalances(completion: @escaping ( ResponseType) -> Void) {
        getTickers(completion: { (_) in
            self.getAccountBalances(completion: { (responseType) in
                completion(responseType)
            })
        })
    }
}
