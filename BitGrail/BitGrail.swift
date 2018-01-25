//
//  BitGrail.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/2/18.
//

import Foundation
import CryptoSwift

extension CurrencyPair {
    
    var bitGrailLabel: String {
        return quantity.code + "/" + price.code
    }
    
    convenience init(bitGrailLabel: String, currencyStore: CurrencyStoreType) {
        let currencySymbols = bitGrailLabel.components(separatedBy: "/")
        let quantity = currencyStore.forCode(currencySymbols[0])
        let price = currencyStore.forCode(currencySymbols[1])
        self.init(quantity: quantity, price: price)
    }
}

public struct BitGrail {
    
    public class Market: Ticker {
        public var market: String = ""
        public var last = NSDecimalNumber.zero
        public var high = NSDecimalNumber.zero
        public var low = NSDecimalNumber.zero
        public var volume = NSDecimalNumber.zero
        public var coinVolume = NSDecimalNumber.zero
        public var bid = NSDecimalNumber.zero
        public var ask = NSDecimalNumber.zero
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            
            market = json["market"] as? String ?? ""
            last = NSDecimalNumber(json["last"])
            high = NSDecimalNumber(json["High"])
            low = NSDecimalNumber(json["Low"])
            volume = NSDecimalNumber(json["Volume"])
            coinVolume = NSDecimalNumber(json["coinVolume"])
            ask = NSDecimalNumber(json["ask"])
            bid = NSDecimalNumber(json["bid"])
            super.init(symbol: CurrencyPair(bitGrailLabel: market, currencyStore: currencyStore), price: last)
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
        case getMarkets
        case getBalance
    }
    
    public class Store: ExchangeDataStore<Market, Balance, Order> {
        public static var shared = Store()
        
        override private init() {
            super.init()
            name = "BitGrail"
            accountingCurrency = .Bitcoin
        }
        
        public var tickersResponse: HTTPURLResponse? = nil
        public var balanceResponse: HTTPURLResponse? = nil
    }
    
    public class Service: Network, TickerServiceType, BalanceServiceType {
        private let key: String
        private let secret: String
        fileprivate let store = BitGrail.Store.shared
        
        public required init(key: String, secret: String, session: URLSession, userPreference: UserPreference) {
            self.key = key
            self.secret = secret
            super.init(session: session, userPreference: userPreference)
        }
                
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            let apiType = BitGrail.API.getMarkets
            if apiType.checkInterval(response: store.tickersResponse) {
                completion(.cached)
            } else {
                bitGrailDataTaskFor(api: apiType) { (json, response, error) in
                    guard let markets = json as? [String: Any] else { return }
                    
                    var tickers: [Market] = []
                    markets.forEach({ (keyValue) in
                        if let tickersArray = keyValue.value as? [[String: String]] {
                            for tickerJSON in tickersArray {
                                tickers.append(Market(json: tickerJSON, currencyStore: self.userPreference.currencyStore))
                            }
                        }
                    })
                    self.store.setTickersInDictionary(tickers: tickers)
                    self.store.tickersResponse = response
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func getBalances(completion: @escaping (ResponseType) -> Void) {
            let apiType = BitGrail.API.getBalance
            
            if apiType.checkInterval(response: store.balanceResponse) {
                
                completion(.cached)
                
            } else {
                
                bitGrailDataTaskFor(api: apiType) { (json, response, error) in
                    guard let balancesJSON = json as? [String: Any] else { return }
                    
                    var balances: [Balance] = []
                    balancesJSON.forEach({ (arg) in
                        guard let value = arg.value as? [String: String] else { return }
                        let currency = self.userPreference.currencyStore.forCode(arg.key)
                        balances.append(Balance(json: value, currency: currency))
                    })

                    self.store.balances = balances
                    self.store.balanceResponse = response
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        func bitGrailDataTaskFor(api: APIType, completion: ((Any?, HTTPURLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (json, httpResponse, error) in
                guard let json = json as? [String: Any] else { return }
                if let success = json["success"] as? Int, let jsonData = json["response"], success == 1 {
                    completion?(jsonData, httpResponse, error)
                } else {
                    // Handle error here
                }
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            if api.authenticated {
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

extension BitGrail.API: APIType {
    public var host: String {
        return "https://bitgrail.com/api/"
    }
    
    public var path: String {
        switch self {
        case .getMarkets: return "v1/markets"
        case .getBalance: return "v1/balances"
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
        case .getMarkets: return .url
        case .getBalance: return .url
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
