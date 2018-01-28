//
//  CoinMarketCap.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/2/18.
//

import Foundation
import CryptoSwift


public struct CoinMarketCap {
    
    public class CMCTicker: Ticker {
        public var id: String = ""
        public var rank: String = ""
        public var volume24Hrs = NSDecimalNumber.zero
        public var marketCap = NSDecimalNumber.zero
        public var availableSupply = NSDecimalNumber.zero
        public var totalSupply = NSDecimalNumber.zero
        public var changeIn1Hr = NSDecimalNumber.zero
        public var changeIn24Hrs = NSDecimalNumber.zero
        public var changeIn7Days = NSDecimalNumber.zero
        public var lastUpdated = ""
        
        public init(json: [String: Any]) {
            let currency = Currency(name: json["name"] as? String ?? "", code: json["symbol"] as? String ?? "")
            let currencyPair = CurrencyPair(quantity: currency, price: .USD)
            let priceUSD = NSDecimalNumber(json["price_usd"])
            super.init(symbol: currencyPair, price: priceUSD)
            id = json["id"] as? String ?? ""
            rank = json["rank"] as? String ?? ""
            priceInUSD = priceUSD
            priceInBTC = NSDecimalNumber(json["price_btc"])
            volume24Hrs = NSDecimalNumber(json["24h_volume_usd"])
            marketCap = NSDecimalNumber(json["market_cap_usd"])
            availableSupply = NSDecimalNumber(json["available_supply"])
            totalSupply = NSDecimalNumber(json["total_supply"])
            changeIn1Hr = NSDecimalNumber(json["percent_change_1h"])
            changeIn24Hrs = NSDecimalNumber(json["percent_change_24h"])
            changeIn7Days = NSDecimalNumber(json["percent_change_7d"])
            lastUpdated = json["last_updated"] as? String ?? ""
        }
    }
    
    public struct GlobalMarketData {
        public var marketCap: NSDecimalNumber
        public var volume24Hrs: NSDecimalNumber
        public var bitcoinDominance: NSDecimalNumber
        public var activeCurrencies: NSDecimalNumber
        public var activeAssets: NSDecimalNumber
        public var activeMarkets: NSDecimalNumber
        public var lastUpdated: NSDecimalNumber
        
        public init(json: [String: Any]) {
            marketCap = NSDecimalNumber(json["total_market_cap_usd"])
            volume24Hrs = NSDecimalNumber(json["total_24h_volume_usd"])
            bitcoinDominance = NSDecimalNumber(json["bitcoin_percentage_of_market_cap"])
            activeCurrencies = NSDecimalNumber(json["active_currencies"])
            activeAssets = NSDecimalNumber(json["active_assets"])
            activeMarkets = NSDecimalNumber(json["active_markets"])
            lastUpdated = NSDecimalNumber(json["last_updated"])
        }
        
        public var description: String {
            var string = ""
            string += "MrktCp " + marketCap.shortFormatted + " | "
            string += "24hVol " + volume24Hrs.shortFormatted + " | "
            string += bitcoinDominance.stringValue + "% btc"
            return string
        }
    }
    
    public class Balance: Cryptex.Balance {
        public let reserved: NSDecimalNumber
        
        public init(json: [String: String], currency: Currency) {
            reserved = NSDecimalNumber(json["reserved"])
            super.init(currency: currency, quantity: NSDecimalNumber(json["balance"]))
        }
    }
    
    public enum API {
        case getTicker
        case getGlobal
    }
    
    public class Store: ExchangeDataStore<CMCTicker, Balance> {
                
        override fileprivate init() {
            super.init()
            name = "CoinMarketCap"
            accountingCurrency = .USD
        }
        
        public var tickerResponse: (response: HTTPURLResponse?, tickers: [CMCTicker]) = (nil, [])
        public var globalMarketDataResponse: (response: HTTPURLResponse?, globalData: GlobalMarketData?) = (nil, nil)
    }
    
    public class Service: Network, TickerServiceType {
        public let store = Store()
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            let apiType = CoinMarketCap.API.getTicker
            if apiType.checkInterval(response: store.tickerResponse.response) {
                completion(.cached)
            } else {
                coinExchangeDataTaskFor(api: apiType) { (response) in
                    guard let marketSummaries = response.json as? [[String: String]] else { return }
                    
                    let tickers: [CMCTicker] = marketSummaries.flatMap { CMCTicker(json: $0) }
                    self.store.setTickersInDictionary(tickers: tickers)
                    
                    self.store.tickerResponse = (response.httpResponse, tickers)
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func getGlobal(completion: @escaping (ResponseType) -> Void) {
            let apiType = CoinMarketCap.API.getGlobal
            if apiType.checkInterval(response: store.globalMarketDataResponse.response) {
                completion(.cached)
            } else {
                coinExchangeDataTaskFor(api: apiType) { (response) in
                    guard let global = response.json as? [String: Any] else { return }
                    self.store.globalMarketDataResponse = (response.httpResponse, GlobalMarketData(json: global))
                    completion(.fetched)
                    }.resume()
            }
        }
        
        func coinExchangeDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                completion?(response)
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

extension CoinMarketCap.API: APIType {
    public var host: String {
        return "https://api.coinmarketcap.com/"
    }
    
    public var path: String {
        switch self {
        case .getTicker: return "v1/ticker?limit=0"
        case .getGlobal: return "v1/global"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .getTicker: return .GET
        case .getGlobal: return .GET
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .getTicker: return false
        case .getGlobal: return false
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getTicker: return .response
        case .getGlobal: return .response
        }
    }
    
    public var postData: [String : String] {
        switch self {
        case .getTicker: return [:]
        case .getGlobal: return [:]
        }
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getTicker: return .aMinute
        case .getGlobal: return .aMinute
        }
    }
}
