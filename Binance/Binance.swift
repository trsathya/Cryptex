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
    public struct Ticker: Comparable {
        public let symbol: CurrencyPair
        public let price: NSDecimalNumber
        public var priceInUSD = NSDecimalNumber.zero
        
        public init(symbol: CurrencyPair, price: NSDecimalNumber) {
            self.symbol = symbol
            self.price = price
        }
        
        public static func <(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedAscending
        }
        
        public static func >(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedDescending
        }
        
        public static func ==(lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.priceInUSD.compare(rhs.priceInUSD) == .orderedSame
        }
    }
    
    public struct Account {
        public let makerCommission: NSDecimalNumber
        public let takerCommission: NSDecimalNumber
        public let buyerCommission: NSDecimalNumber
        public let sellerCommission: NSDecimalNumber
        public let canTrade: Bool
        public let canWithdraw: Bool
        public let canDeposit: Bool
        public let balances: [Balance]
        
        public init?(json: [String: Any], currencyStore: CurrencyStoreType.Type) {
            makerCommission = NSDecimalNumber(any: json["makerCommission"])
            takerCommission = NSDecimalNumber(any: json["takerCommission"])
            buyerCommission = NSDecimalNumber(any: json["buyerCommission"])
            sellerCommission = NSDecimalNumber(any: json["sellerCommission"])
            canTrade = json["canTrade"] as? Bool ?? false
            canWithdraw = json["canWithdraw"] as? Bool ?? false
            canDeposit = json["canDeposit"] as? Bool ?? false
            if let balancesJSON = json["balances"] as? [[String: String]] {
                balances = balancesJSON.flatMap { Balance(json: $0, currencyStore: currencyStore) }
            } else {
                balances = []
            }
        }
        
        public struct Balance: BalanceType {
            public var currency: Currency
            public var quantity: NSDecimalNumber
            public var locked: NSDecimalNumber
            
            public init?(json: [String: String], currencyStore: CurrencyStoreType.Type) {
                currency = currencyStore.forCode(json["asset"] ?? "")
                guard
                    let freeString = json["free"]
                    , let lockedString = json["locked"]
                    , freeString != "0.00000000" || lockedString != "0.00000000"
                    else { return nil }
                quantity = NSDecimalNumber(string: freeString)
                locked = NSDecimalNumber(string: lockedString)
            }
        }
    }
    
    public class Store: ExchangeDataStoreType {
        public static var shared = Store()
        
        public var name: String = "Binance"
        
        private init() { }
        
        public var tickersResponse: (response: HTTPURLResponse?, products: [Binance.Ticker]) = (nil, [])
        public var binanceTickerByQuantityCCY: [[Binance.Ticker]] = []
        public var binanceTickerByPriceCCY: [[Binance.Ticker]] = []
        public var binanceTickerByName: [[Binance.Ticker]] = []
        public var accountResponse: (response: HTTPURLResponse?, account: Binance.Account?) = (nil, nil)
    }
    
    public enum API {
        case getAllPrices
        case account
    }
    
    public class Service: Network {
        
        private let key: String
        private let secret: String
        fileprivate let store = Binance.Store.shared
        
        public required init(key: String, secret: String, session: URLSession, userPreference: UserPreference) {
            self.key = key
            self.secret = secret
            super.init(session: session, userPreference: userPreference)
        }
        
        public func balanceInPreferredCurrency(balance: BalanceType) -> NSDecimalNumber {
            let fiatCurrencyPair = CurrencyPair(quantity: balance.currency, price: userPreference.fiat)
            let cryptoCurrencyPair = CurrencyPair(quantity: balance.currency, price: userPreference.crypto)
            
            if let ticker = (store.binanceTickerByName.first?.filter {$0.symbol == fiatCurrencyPair})?.first {
                
                return balance.quantity.multiplying(by: ticker.priceInUSD)
                
            } else if let ticker = (store.binanceTickerByName.first?.filter {$0.symbol == cryptoCurrencyPair})?.first {
                
                return balance.quantity.multiplying(by: ticker.priceInUSD)
                
            } else {
                
                return balance.quantity
                
            }
        }
        
        public func getTotalBalance() -> NSDecimalNumber {
            var totalBalance = NSDecimalNumber.zero
            store.accountResponse.account?.balances.forEach { balance in
                let balanceInPreferredCurrency = self.balanceInPreferredCurrency(balance: balance)
                totalBalance = totalBalance.adding(balanceInPreferredCurrency)
            }
            return totalBalance
        }
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            
            let apiType = Binance.API.getAllPrices
            
            if apiType.checkInterval(response: store.tickersResponse.response) {
                
                completion(.cached)
                
            } else {
                
                binanceDataTaskFor(api: apiType, completion: { (json, httpResponse, error) in
                    guard
                        let tickerArray = json as? [[String: String]]
                        else {
                            print("Error: Cast Failed in \(#function)")
                            return
                    }
                    
                    var tickers: [Binance.Ticker] = []
                    for ticker in tickerArray {
                        let currencyPair = CurrencyPair(symbol: ticker["symbol"] ?? "", currencyStore: self.userPreference.currencyStore)
                        let price = NSDecimalNumber(string: ticker["price"])
                        let ticker = Binance.Ticker(symbol: currencyPair, price: price)
                        tickers.append(ticker)
                    }
                    
                    tickers = tickers.map({ (ticker) -> Binance.Ticker in
                        if ticker.symbol.price == self.userPreference.fiat {
                            var t = ticker
                            t.priceInUSD = ticker.price
                            return t
                        } else if let usdPrice = tickers.filter({ (innerTicker) -> Bool in
                            return ticker.symbol.price == innerTicker.symbol.quantity && innerTicker.symbol.price == self.userPreference.fiat
                        }).first?.price {
                            var t = ticker
                            t.priceInUSD = usdPrice.multiplying(by: ticker.price)
                            return t
                        }
                        return ticker
                    })
                    
                    var byQuantityCCY: [Currency: [Binance.Ticker]] = [:]
                    var byPriceCCY: [Currency: [Binance.Ticker]] = [:]
                    
                    Set(tickers.map { $0.symbol.quantity }).forEach { quantity in
                        byQuantityCCY[quantity] = []
                    }
                    
                    Set(tickers.map { $0.symbol.price }).forEach { price in
                        byPriceCCY[price] = []
                    }
                    
                    tickers.forEach { ticker in
                        byQuantityCCY[ticker.symbol.quantity]?.append(ticker)
                        byPriceCCY[ticker.symbol.price]?.append(ticker)
                    }
                    
                    
                    self.store.binanceTickerByQuantityCCY = byQuantityCCY.values.sorted(by: { (leftArray, rightArray) -> Bool in
                        guard let left = leftArray.first, let right = rightArray.first else { return false }
                        return left.priceInUSD.compare(right.priceInUSD) == .orderedDescending
                    })
                    self.store.binanceTickerByPriceCCY = byPriceCCY.keys.flatMap { byPriceCCY[$0] }
                    self.store.binanceTickerByName = [tickers]
                    self.store.tickersResponse = (httpResponse, tickers)
                    completion(.fetched)
                    
                }).resume()
            }
        }
        
        public func getAccount(completion: @escaping (ResponseType) -> Void) {
            let apiType = Binance.API.account
            if apiType.checkInterval(response: store.accountResponse.response) {
                completion(.cached)
            } else {
                binanceDataTaskFor(api: apiType) { (json, httpResponse, error) in
                    guard let json = json as? [String: Any] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    self.store.accountResponse = (httpResponse, Binance.Account(json: json, currencyStore: self.userPreference.currencyStore))
                    completion(.fetched)
                    }.resume()
            }
        }
        
        func binanceDataTaskFor(api: APIType, completion: ((Any?, HTTPURLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (json, httpResponse, error) in
                // Handle error here
                api.print(json, content: .response)
                completion?(json, httpResponse, error)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if api.authenticated {
                
                var postData = api.postData
                postData["recvWindow"] = "5000"
                postData["timestamp"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
                
                if let hmac_sha = try? HMAC(key: secret, variant: .sha256).authenticate(Array(postData.queryString.utf8)) {
                    let signature = Data(bytes: hmac_sha).toHexString()
                    postData["signature"] = signature
                }
                
                var postDataString = ""
                if let data = data(postData), let string = String(data: data, encoding: .utf8), postData.count > 0 {
                    
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

public extension Binance.Service {
    
    func getTickersAndBalances(completion: @escaping ( ResponseType) -> Void) {
        getTickers(completion: { (_) in
            self.getAccount(completion: { (response) in
                completion(response)
            })
        })
    }
}
