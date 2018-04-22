//
//  CoinExchange.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/2/18.
//

import Foundation
import CryptoSwift

extension CurrencyPair {
    
    var coinExchangeLabel: String {
        return quantity.code + "/" + price.code
    }
    
    convenience init(coinExchangeLabel: String, currencyStore: CurrencyStoreType) {
        let currencySymbols = coinExchangeLabel.components(separatedBy: "/")
        let quantity = currencyStore.forCode(currencySymbols[0])
        let price = currencyStore.forCode(currencySymbols[1])
        self.init(quantity: quantity, price: price)
    }
}

public struct CoinExchange {
    
    public class Market: CurrencyPair {
        public var marketID: String = ""
        public var marketAssetName: String = ""
        public var marketAssetCode: String = ""
        public var marketAssetID: String = ""
        public var marketAssetType: String = ""
        public var baseCurrency: String = ""
        public var baseCurrencyCode: String = ""
        public var baseCurrencyID: String = ""
        public var active: Bool
        
        public init(json: [String: Any]) {
            marketID = json["MarketID"] as? String ?? ""
            marketAssetName = json["MarketAssetName"] as? String ?? ""
            marketAssetCode = json["MarketAssetCode"] as? String ?? ""
            marketAssetID = json["MarketAssetID"] as? String ?? ""
            marketAssetType = json["MarketAssetType"] as? String ?? ""
            baseCurrency = json["BaseCurrency"] as? String ?? ""
            baseCurrencyCode = json["BaseCurrencyCode"] as? String ?? ""
            baseCurrencyID = json["BaseCurrencyID"] as? String ?? ""
            active = json["Active"] as? Bool ?? false
            let quantityCurrency = Currency(name: marketAssetName, code: marketAssetCode)
            let priceCurrency = Currency(name: baseCurrency, code: baseCurrencyCode)
            super.init(quantity: quantityCurrency, price: priceCurrency)
        }
    }
    
    public class MarketSummary: Ticker {
        public var marketID: String = ""
        public var lastPrice = NSDecimalNumber.zero
        public var change = NSDecimalNumber.zero
        public var highPrice = NSDecimalNumber.zero
        public var lowPrice = NSDecimalNumber.zero
        public var volume = NSDecimalNumber.zero
        public var btcVolume = NSDecimalNumber.zero
        public var tradeCount = NSDecimalNumber.zero
        public var bidPrice = NSDecimalNumber.zero
        public var askPrice = NSDecimalNumber.zero
        public var buyOrderCount = NSDecimalNumber.zero
        public var sellOrderCount = NSDecimalNumber.zero
        
        public init?(json: [String: Any], markets: [String: Market]) {
            marketID = json["MarketID"] as? String ?? ""
            guard let market = markets[marketID] else { return nil }
            lastPrice = NSDecimalNumber(json["LastPrice"])
            change = NSDecimalNumber(json["Change"])
            highPrice = NSDecimalNumber(json["HighPrice"])
            lowPrice = NSDecimalNumber(json["LowPrice"])
            volume = NSDecimalNumber(json["Volume"])
            btcVolume = NSDecimalNumber(json["BTCVolume"])
            tradeCount = NSDecimalNumber(json["TradeCount"])
            bidPrice = NSDecimalNumber(json["BidPrice"])
            askPrice = NSDecimalNumber(json["AskPrice"])
            buyOrderCount = NSDecimalNumber(json["BuyOrderCount"])
            sellOrderCount = NSDecimalNumber(json["SellOrderCount"])
            super.init(symbol: CurrencyPair(quantity: market.quantity, price: market.price), price: lastPrice)
        }
    }
    
    public struct MarketHistory {
        public let tradePairId: Int
        public let label: String
        public let type: String
        public let price: NSDecimalNumber
        public let amount: NSDecimalNumber
        public let total: NSDecimalNumber
        public let timestamp: TimeInterval
    }
    
    public class Balance: Cryptex.Balance {
        public let reserved: NSDecimalNumber
        
        public init(json: [String: String], currency: Currency) {
            reserved = NSDecimalNumber(json["reserved"])
            super.init(currency: currency, quantity: NSDecimalNumber(json["balance"]))
        }
    }
    
    public enum API {
        case getmarkets
        case getmarketsummaries
        case getBalance
    }
    
    public class Store: ExchangeDataStore<MarketSummary, Balance> {
                
        override fileprivate init() {
            super.init()
            name = "CoinExchange"
            accountingCurrency = .USDT
        }
        
        public var currencyPairsResponse: (response: HTTPURLResponse?, currencyPairs: [String: Market]) = (nil, [:])
        public var tickersResponse: HTTPURLResponse? = nil
        public var balanceResponse: HTTPURLResponse? = nil
    }
    
    public class Service: Network, TickerServiceType, BalanceServiceType {
        public let store = Store()
        
        public func getCurrencyPairs(completion: @escaping (ResponseType) -> Void) {
            let apiType = CoinExchange.API.getmarkets
            if apiType.checkInterval(response: store.currencyPairsResponse.response) {
                completion(.cached)
            } else {
                coinExchangeDataTaskFor(api: apiType) { (response) in
                    guard let marketsJSON = response.json as? [[String: Any]] else { return }
                    var markets: [String: Market] = [:]
                    marketsJSON.forEach({ (marketJSON) in
                        let market = Market(json: marketJSON)
                        markets[market.marketID] = market
                    })
                    self.store.currencyPairsResponse = (response.httpResponse, markets)
                    completion(.fetched)
                }.resume()
            }
        }
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            let apiType = CoinExchange.API.getmarketsummaries
            if apiType.checkInterval(response: store.tickersResponse) {
                completion(.cached)
            } else {
                coinExchangeDataTaskFor(api: apiType) { (response) in
                    guard let marketSummaries = response.json as? [[String: String]] else { return }
                    
                    let tickers = marketSummaries.flatMap { MarketSummary(json: $0, markets: self.store.currencyPairsResponse.currencyPairs) }
                    self.store.setTickersInDictionary(tickers: tickers)
                    
                    self.store.tickersResponse = response.httpResponse
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func getBalances(completion: @escaping (ResponseType) -> Void) {
            let apiType = CoinExchange.API.getBalance
            
            if apiType.checkInterval(response: store.balanceResponse) {
                
                completion(.cached)
                
            } else {
                
                coinExchangeDataTaskFor(api: apiType) { (response) in
                    guard let balancesJSON = response.json as? [String: Any] else { return }
                    
                    var balances: [Balance] = []
                    balancesJSON.forEach({ (arg) in
                        guard let value = arg.value as? [String: String] else { return }
                        let currency = self.forCode(arg.key)
                        balances.append(Balance(json: value, currency: currency))
                    })
                    self.store.balances = balances
                    self.store.balanceResponse = response.httpResponse
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        func coinExchangeDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                guard let json = response.json as? [String: Any] else { return }
                if let success = json["success"] as? String, let jsonData = json["result"], Int(success) == 1 {
                    var tempResponse = response
                    tempResponse.json = jsonData
                    completion?(tempResponse)
                } else {
                    api.print(json["message"] ?? "", content: .response)
                }
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            if let key = key, let secret = secret, api.authenticated {
                var postData = api.postData
                postData["nonce"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
                let requestString = postData.queryString
                api.print("Request Data: \(requestString)", content: .response)
                // POST payload
                let requestData = Array(requestString.utf8)
                if case .POST = api.httpMethod {
                    mutableURLRequest.httpBody = requestString.utf8Data()
                }
                
                if let hmac_sha512 = try? HMAC(key: Array(secret.utf8), variant: .sha512).authenticate(requestData) {
                    mutableURLRequest.setValue(hmac_sha512.toHexString(), forHTTPHeaderField: "SIGNATURE")
                }
                mutableURLRequest.setValue(key, forHTTPHeaderField: "KEY")
            }
            return mutableURLRequest
        }
    }
}

extension CoinExchange.API: APIType {
    public var host: String {
        return "https://www.coinexchange.io/api/"
    }
    
    public var path: String {
        switch self {
        case .getmarkets: return "v1/getmarkets"
        case .getmarketsummaries: return "v1/getmarketsummaries"
        case .getBalance: return "v1/balances"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .getmarkets: return .GET
        case .getmarketsummaries: return .GET
        case .getBalance: return .POST
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .getmarkets: return false
        case .getmarketsummaries: return false
        case .getBalance: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getmarkets: return .url
        case .getmarketsummaries: return .url
        case .getBalance: return .url
        }
    }
    
    public var postData: [String : String] {
        switch self {
        case .getmarkets: return [:]
        case .getmarketsummaries: return [:]
        case .getBalance: return [:]
        }
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getmarkets: return .aWeek
        case .getmarketsummaries: return .aMinute
        case .getBalance: return .aMinute
        }
    }
}
