//
//  GDAX.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

extension CurrencyPair {
    
    var gdaxProductId: String {
        return quantity.code + "-" + price.code
    }
    
    convenience init(gdaxProductId: String, currencyStore: CurrencyStoreType) {
        let currencySymbols = gdaxProductId.components(separatedBy: "-")
        let quantity = currencyStore.forCode(currencySymbols[0])
        let price = currencyStore.forCode(currencySymbols[1])
        self.init(quantity: quantity, price: price)
    }
}

public struct GDAX {
    public struct Product {
        public var id: CurrencyPair
        public var baseCurrency: Currency
        public var quoteCurrency: Currency
        public var baseMinSize: NSDecimalNumber
        public var baseMaxSize: NSDecimalNumber
        public var quoteIncrement: NSDecimalNumber
        public var displayName: String
        public var marginEnabled: Bool
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            self.id = CurrencyPair(gdaxProductId: json["id"] as! String, currencyStore: currencyStore)
            self.baseCurrency = currencyStore.forCode(json["base_currency"] as! String)
            self.quoteCurrency = currencyStore.forCode(json["quote_currency"] as! String)
            self.baseMinSize = NSDecimalNumber(json["base_min_size"])
            self.baseMaxSize = NSDecimalNumber(json["base_max_size"])
            self.quoteIncrement = NSDecimalNumber(json["quote_increment"])
            self.displayName = json["display_name"] as! String
            self.marginEnabled = json["margin_enabled"] as! Bool
        }
    }
    
    public class Ticker: Cryptex.Ticker {
        public var tradeId: Int
        public var size: NSDecimalNumber
        public var bid: NSDecimalNumber
        public var ask: NSDecimalNumber
        public var volume: NSDecimalNumber
        public var time: Date
        
        public init(json: [String: Any], symbol: CurrencyPair) {
            self.tradeId = json["trade_id"] as? Int ?? 0
            self.size = NSDecimalNumber(json["size"])
            self.bid = NSDecimalNumber(json["bid"])
            self.ask = NSDecimalNumber(json["ask"])
            self.volume = NSDecimalNumber(json["volume"])
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z" //"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let timeString = json["time"] as? String, let date = dateFormatter.date(from: timeString) {
                self.time = date
            } else {
                self.time = Date()
            }
            super.init(symbol: symbol, price: NSDecimalNumber(json["price"]))
        }
    }
    
    public class Account: Cryptex.Balance {
        public var id: String
        public var available: NSDecimalNumber
        public var hold: NSDecimalNumber
        public var profileId: String
        
        public init?(json: [String: Any], currencyStore: CurrencyStoreType) {
            id = json["id"] as? String ?? ""
            available = NSDecimalNumber(json["available"])
            hold = NSDecimalNumber(json["hold"])
            profileId = json["profile_id"] as? String ?? ""
            super.init(currency: currencyStore.forCode( json["currency"] as? String ?? "" ), quantity: NSDecimalNumber(json["balance"]))
        }
    }
    
    public class Store: ExchangeDataStore<Ticker, Account> {
        
        override fileprivate init() {
            super.init()
            name = "GDAX"
        }
        
        public var productsResponse: (response: HTTPURLResponse?, products: [Product]) = (nil, [])
        public var tickersResponse: [String: (response: HTTPURLResponse?, ticker: GDAX.Ticker)] = [:]
        public var accountsResponse: (response: HTTPURLResponse?, accounts: [Account]) = (nil, [])
    }
    
    public enum API {
        case getProducts
        case getProductTicker(CurrencyPair)
        case listAccounts
    }
    
    public class Service: Network {
        
        private let passphrase: String
        public let store = Store()
        
        public required init(key: String?, secret: String?, passphrase: String, session: URLSession, userPreference: UserPreference, currencyOverrides: [String: Currency]?) {
            self.passphrase = passphrase
            super.init(key: key, secret: secret, session: session, userPreference: userPreference, currencyOverrides: nil)
        }
        
        public func getProducts(completion: @escaping (ResponseType) -> Void) {
            let apiType = GDAX.API.getProducts
            if apiType.checkInterval(response: store.productsResponse.response) {
                completion(.cached)
            } else {
                gdaxDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [[String: Any]] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    
                    self.store.productsResponse = (response.httpResponse, json.map({GDAX.Product(json: $0, currencyStore: self)}).filter { self.userPreference.ignoredFiats.contains($0.quoteCurrency) == false })
                    
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        public func getTicker(symbol: CurrencyPair, completion: @escaping (CurrencyPair, ResponseType) -> Void) {
            
            let apiType = GDAX.API.getProductTicker(symbol)
            
            if apiType.checkInterval(response: store.tickersResponse[symbol.displaySymbol]?.response) {
                
                completion(symbol, .cached)
                
            } else {
                
                gdaxDataTaskFor(api: apiType) { (response) in
                    
                    guard let json = response.json as? [String: Any] else { return }
                    let ticker = GDAX.Ticker(json: json, symbol: symbol)
                    
                    self.store.setTicker(ticker: ticker, symbol: symbol.displaySymbol)
                    self.store.tickersResponse[symbol.displaySymbol] = (response.httpResponse, ticker)
                    completion(symbol, .fetched)
                    
                    }.resume()
            }
        }
        
        public func listAccounts(completion: @escaping (ResponseType) -> Void) {
            
            let apiType = GDAX.API.listAccounts
            
            if apiType.checkInterval(response: store.accountsResponse.response) {
                
                completion(.cached)
                
            } else {
                gdaxDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [[String: Any]] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    let accounts = json.flatMap {GDAX.Account(json: $0, currencyStore: self)}
                    self.store.balances = accounts
                    self.store.accountsResponse = (response.httpResponse, accounts)
                    completion(.fetched)
                    }.resume()
            }
        }
        
        func gdaxDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                // Handle error here
                completion?(response)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if let key = key, let secret = secret, api.authenticated {
                
                var postDataString = ""
                if let data = api.postData.data, let string = data.string, api.postData.count > 0 {
                    
                    postDataString = string
                    
                    // POST payload
                    if case .POST = api.httpMethod {
                        mutableURLRequest.httpBody = data
                    }
                    
                    api.print("Request Data: \(postDataString)", content: .response)
                }
                
                let ts = "\(Date().timeIntervalSince1970)"
                var prehash = ts + api.httpMethod.rawValue + api.path + postDataString
                
                if let bytes = Data(base64Encoded: secret)?.bytes, let hmac_sha = try? HMAC(key: bytes, variant: .sha256).authenticate(Array(prehash.utf8)), let signature = hmac_sha.toBase64() {
                    mutableURLRequest.setValue(signature, forHTTPHeaderField: "CB-ACCESS-SIGN")
                }
                
                mutableURLRequest.setValue(ts, forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
                mutableURLRequest.setValue(passphrase, forHTTPHeaderField: "CB-ACCESS-PASSPHRASE")
                mutableURLRequest.setValue(key, forHTTPHeaderField: "CB-ACCESS-KEY")
            }
            
            return mutableURLRequest
        }
    }
}

extension GDAX.API: APIType {
    public var host: String {
        return "https://api.gdax.com"
    }
    
    public var path: String {
        switch self {
        case .getProducts:                          return "/products"
        case .getProductTicker(let currencyPair):   return "/products/\(currencyPair.gdaxProductId)/ticker"
        case .listAccounts: return "/accounts"
        }
    }
    
    public var httpMethod: HttpMethod {
        return .GET
    }
    
    public var authenticated: Bool {
        switch self {
        case .listAccounts: return true
        default: return false
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getProducts: return .url
        case .getProductTicker(_): return .url
        case .listAccounts: return .url
        }
    }
    
    public var postData: [String: String] {
        return [:]
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getProducts:          return .aMonth
        case .getProductTicker(_):  return .aMinute
        case .listAccounts:         return .aMinute
        }
    }
}

extension GDAX.Service: TickerServiceType, BalanceServiceType {
    
    public func getBalances(completion: @escaping (ResponseType) -> Void) {
        getProducts(completion: { (_) in
            var tasks: [String: Bool] = [:]
            
            self.store.productsResponse.products.forEach { product in
                tasks[product.id.displaySymbol] = false
            }
            
            self.store.productsResponse.products.forEach { product in
                self.getTicker(symbol: product.id, completion: { _,_  in
                    tasks[product.id.displaySymbol] = true
                    
                    let flag = tasks.values.reduce(true, { (result, value) -> Bool in
                        return result && value
                    })
                    
                    if flag {
                        self.listAccounts(completion: { (responseType) in
                            completion(responseType)
                        })
                    }
                })
            }
        })
    }
    
    public func getTickers(completion: @escaping (ResponseType) -> Void) {
        getProducts(completion: { (_) in
            self.store.productsResponse.products.forEach { product in
                self.getTicker(symbol: product.id, completion: { (_, responseType) in
                    completion(responseType)
                })
            }
        })
    }
}
