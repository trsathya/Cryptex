//
//  Gemini.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Gemini {
    public class Ticker: Cryptex.Ticker {
        public var bid: NSDecimalNumber
        public var ask: NSDecimalNumber
        public var last: NSDecimalNumber
        public var volume: Volume?
        
        public init?(json: Any?, for symbol: CurrencyPair) {
            guard let json = json as? [String: Any] else { return nil }
            
            bid = NSDecimalNumber(json["bid"])
            ask = NSDecimalNumber(json["ask"])
            last = NSDecimalNumber(json["last"])
            super.init(symbol: symbol, price: last)
            volume = Volume(json: json["volume"], for: symbol)
        }
        
        public struct Volume {
            public var timestamp: Date?
            public var price: String?
            public var quantity: String?
            
            public init?(json: Any?, for symbol: CurrencyPair) {
                guard let json = json as? [String: Any] else { return nil }
                price = json[symbol.price.code] as? String
                quantity = json[symbol.quantity.code] as? String
                if let time = json["timestamp"] as? Double {
                    timestamp = Date(timeIntervalSince1970: time/1000)
                } else {
                    timestamp = nil
                }
            }
        }
    }
    
    public struct CurrentOrderBook {
        public var bids: [LimitOrder]
        public var asks: [LimitOrder]
        
        public init?(json: Any?) {
            guard let json = json as? [String: Any] else { return nil }
            
            if let array = json["bids"] as? [Any] {
                bids = array.flatMap({ bid -> LimitOrder? in
                    return LimitOrder(json: bid)
                })
            } else {
                bids = [LimitOrder]()
            }
            
            if let array = json["asks"] as? [Any] {
                asks = array.flatMap({ ask -> LimitOrder? in
                    return LimitOrder(json: ask)
                })
            } else {
                asks = [LimitOrder]()
            }
        }
    }
    
    public struct LimitOrder {
        public var price: String?
        public var amount: String?
        
        public init?(json: Any?) {
            guard let json = json as? [String: String] else { return nil }
            price = json["price"]
            amount = json["amount"]
        }
    }
    
    public class Balance: Cryptex.Balance {
        public var availableForTrading: NSDecimalNumber
        public var availableForWithdrawal: NSDecimalNumber
        public var type: String
        
        public init?(json: Any?, currencyStore: CurrencyStoreType) {
            guard let json = json as? [String: Any] else { return nil }
            availableForTrading = NSDecimalNumber(json["available"])
            availableForWithdrawal = NSDecimalNumber(json["availableForWithdrawal"])
            type = json["type"] as! String
            super.init(currency: currencyStore.forCode(json["currency"] as! String), quantity: NSDecimalNumber(json["amount"]))
        }
    }
    
    public struct PastTrade {
        public var price: NSDecimalNumber
        public var amount: NSDecimalNumber
        public var timestamp: Date
        public var type: TransactionType = .none
        public var aggressor: Bool
        public var feeCurrency: Currency
        public var feeAmount: NSDecimalNumber
        public var tid: UInt32
        public var orderId: String
        public var exchange: String
        public var isAuctionFill: Bool
        
        public init?(json: [String: Any], currencyStore: CurrencyStoreType) {
            price = NSDecimalNumber(json["price"])
            amount = NSDecimalNumber(json["amount"])
            timestamp = Date(timeIntervalSince1970: (json["timestampms"] as! TimeInterval)/1000)
            if let string = json["type"] as? String, let value = TransactionType(rawValue: string.lowercased()) {
                type = value
            }
            aggressor = json["aggressor"] as! Bool
            feeCurrency = currencyStore.forCode(json["fee_currency"] as! String)
            feeAmount = NSDecimalNumber(json["fee_amount"])
            tid = json["tid"] as! UInt32
            orderId = json["order_id"] as! String
            exchange = json["exchange"] as! String
            isAuctionFill = json["is_auction_fill"] as! Bool
        }
    }
    
    public class Store: ExchangeDataStore<Ticker, Balance> {
        
        override fileprivate init() {
            super.init()
            name = "Gemini"
        }
        
        public var symbolsResponse: (response: HTTPURLResponse?, symbols: [CurrencyPair]) = (nil, [])
        public var tickerResponse: [String: HTTPURLResponse] = [:]
        public var balanceResponse: HTTPURLResponse? = nil
        public var pastTradesResponse: [String: (response: HTTPURLResponse?, pastTrades: [Gemini.PastTrade])] = [:]
        public var currentOrderBookResponse: (response: HTTPURLResponse?, currentorderBook: Gemini.CurrentOrderBook?) = (nil, nil)
    }
    
    public enum API {
        case symbols
        case ticker(String)
        case currentOrderBook(String)
        case tradeHistory(String)
        case currentAuction(String)
        case auctionHistory(String)
        
        // Order Placement APIs
        case newOrder
        case cancelOrder
        case cancelAllSessionOrders
        case cancelAllActiveOrders
        // Order Status APIs
        case orderStatus
        case getActiveOrders
        case getPastTrades(CurrencyPair)
        case getTradeVolume
        // Fund Management APIs
        case getAvailableBalances
        case newDepositAddress(Currency)
        case withdrawCryptoFundsToWhitelistedAddress(Currency)
        // Session APIs
        case heartbeat
    }
    
    public class Service: Network {
        
        public let store = Store()
        
        public func getSymbols(completion: @escaping (ResponseType) -> Void) {
            let apiType = Gemini.API.symbols
            if apiType.checkInterval(response: store.symbolsResponse.response) {
                completion(.cached)
            } else {
                geminiDataTaskFor(api: apiType, completion: { (response) in
                    guard let json = response.json, let stringArray = json as? [String] else {
                        completion(.unexpected(response))
                        return
                    }
                    let geminiSymbols = stringArray.flatMap { CurrencyPair(symbol: $0, currencyStore: self) }
                    self.store.symbolsResponse = (response.httpResponse, geminiSymbols)
                    completion(.fetched)
                }, failure: nil).resume()
            }
        }
        
        public func getTicker(symbol: CurrencyPair, completion: @escaping (CurrencyPair, ResponseType) -> Void) {
            let apiType = Gemini.API.ticker(symbol.displaySymbol)
            if apiType.checkInterval(response: store.tickerResponse[symbol.displaySymbol]) {
                completion(symbol, .cached)
            } else {
                geminiDataTaskFor(api: apiType, completion: { (response) in
                    guard let json = response.json, let ticker = Gemini.Ticker(json: json, for: symbol) else {
                        completion(symbol, .unexpected(response))
                        return
                    }
                    
                    self.store.setTicker(ticker: ticker, symbol: symbol.displaySymbol)
                    self.store.tickerResponse[symbol.displaySymbol] = response.httpResponse
                    completion(symbol, .fetched)
                }, failure: nil).resume()
            }
        }
        
        public func getCurrentOrderBook(symbol: CurrencyPair, completion: @escaping (ResponseType) -> Void) {
            let apiType = Gemini.API.currentOrderBook(symbol.displaySymbol)
            if apiType.checkInterval(response: store.symbolsResponse.response) {
                completion(.cached)
            } else {
                geminiDataTaskFor(api: apiType, completion: { (response) in
                    guard let json = response.json, let currentOrderBook = Gemini.CurrentOrderBook(json: json) else {
                        completion(.unexpected(response))
                        return
                    }
                    self.store.currentOrderBookResponse = (response.httpResponse, currentOrderBook)
                    completion(.fetched)
                }, failure: nil).resume()
            }
        }
        
        public func getAvailableBalances(completion: @escaping (ResponseType) -> Void, failure: ((String?, String?) -> Void)?) {
            let apiType = Gemini.API.getAvailableBalances
            if apiType.checkInterval(response: store.balanceResponse) {
                completion(.cached)
            } else {
                geminiDataTaskFor(api: apiType, completion: { (response) in
                    guard let array = response.json as? [[String: Any]] else {
                        completion(.unexpected(response))
                        return
                        
                    }
                    let balances = array.flatMap {Gemini.Balance(json: $0, currencyStore: self)}
                    self.store.balances = balances
                    self.store.balanceResponse = response.httpResponse
                    completion(.fetched)
                }, failure: failure).resume()
            }
        }
        
        public func getPastTrades(currencyPair: CurrencyPair, completion: @escaping (CurrencyPair, ResponseType) -> Void, failure: @escaping (String?, String?) -> Void) {
            let apiType = Gemini.API.getPastTrades(currencyPair)
            if apiType.checkInterval(response: store.pastTradesResponse[currencyPair.displaySymbol]?.response) {
                completion(currencyPair, .cached)
            } else {
                geminiDataTaskFor(api: apiType, completion: { (response) in
                    guard let array = response.json as? [[String: Any]] else {
                        completion(currencyPair, .unexpected(response))
                        return
                    }
                    let pastTrades = array.flatMap {Gemini.PastTrade(json: $0, currencyStore: self)}
                    self.store.pastTradesResponse[currencyPair.displaySymbol] = (response.httpResponse, pastTrades)
                    completion(currencyPair, .fetched)
                }, failure: failure).resume()
            }
        }
        
        func geminiDataTaskFor(api: APIType, completion: ((Response) -> Void)?, failure: ((String?, String?) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                if let json = response.json as? [String: String], let result = json["result"], result == "error" {
                    failure?(json["reason"], json["message"])
                } else {
                    completion?(response)
                }
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            guard let key = key, let secret = secret, api.authenticated else { return mutableURLRequest }
            
            var postDataDictionary = api.postData
            if isMock {
                let postDataString = postDataDictionary.queryString
                if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
                    urlComponents.query = postDataString
                    mutableURLRequest.url = urlComponents.url
                }
            } else {
                postDataDictionary["nonce"] = "\(getTimestampInSeconds())"
                
                var base64EncodedPostDataString = ""
                if let data = postDataDictionary.data {
                    base64EncodedPostDataString = data.base64EncodedString()
                }
                
                mutableURLRequest.setValue(base64EncodedPostDataString, forHTTPHeaderField: "X-GEMINI-PAYLOAD")
                
                do {
                    let sha384hmac = try HMAC(key: secret, variant: .sha384)
                    let signature = try sha384hmac.authenticate(Array(base64EncodedPostDataString.utf8))
                    let signatureHex = signature.toHexString()
                    mutableURLRequest.setValue(signatureHex, forHTTPHeaderField: "X-GEMINI-SIGNATURE")
                } catch {
                    print(error)
                }
                mutableURLRequest.setValue(key, forHTTPHeaderField: "X-GEMINI-APIKEY")
            }
            return mutableURLRequest
        }
    }
}

extension Gemini.API: APIType {
    
    public var host: String {
        return "https://api.gemini.com"
    }
    
    public var path: String {
        switch self {
        case .symbols: return "/v1/symbols"
        case .ticker(let symbol): return "/v1/pubticker/\(symbol)"
        case .currentOrderBook(let symbol): return "/v1/book/\(symbol)"
        case .tradeHistory(let symbol): return "/v1/trades/\(symbol)"
        case .currentAuction(let symbol): return "/v1/auction/\(symbol)"
        case .auctionHistory(let symbol): return "/v1/auction/\(symbol)/history"
        case .newOrder: return "/v1/order/new"
        case .cancelOrder: return "/v1/order/cancel"
        case .cancelAllSessionOrders: return "/v1/order/cancel/session"
        case .cancelAllActiveOrders: return "/v1/order/cancel/all"
        case .orderStatus: return "/v1/order/status"
        case .getActiveOrders: return "/v1/orders"
        case .getPastTrades(_): return "/v1/mytrades"
        case .getTradeVolume: return "/v1/tradevolume"
        case .getAvailableBalances: return "/v1/balances"
        case .newDepositAddress(let currency): return "/v1/deposit/\(currency.code)/newAddress"
        case .withdrawCryptoFundsToWhitelistedAddress(let currency): return "/v1/withdraw/\(currency.code)"
        case .heartbeat: return "/v1/heartbeat"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .symbols:              return .GET
        case .ticker(_):            return .GET
        case .currentOrderBook(_):  return .GET
        case .tradeHistory(_):      return .GET
        case .currentAuction(_):    return .GET
        case .auctionHistory(_):    return .GET
        case .newOrder:             return .POST
        case .cancelOrder:          return .POST
        case .cancelAllSessionOrders: return .POST
        case .cancelAllActiveOrders: return .POST
        case .orderStatus:          return .POST
        case .getActiveOrders:      return .POST
        case .getPastTrades(_):     return .POST
        case .getTradeVolume:       return .POST
        case .getAvailableBalances: return .POST
        case .newDepositAddress(_): return .POST
        case .withdrawCryptoFundsToWhitelistedAddress(_): return .POST
        case .heartbeat:            return .POST
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .symbols:              return false
        case .ticker(_):            return false
        case .currentOrderBook(_):  return false
        case .tradeHistory(_):      return false
        case .currentAuction(_):    return false
        case .auctionHistory(_):    return false
        case .newOrder:             return true
        case .cancelOrder:          return true
        case .cancelAllSessionOrders: return true
        case .cancelAllActiveOrders: return true
        case .orderStatus:          return true
        case .getActiveOrders:      return true
        case .getPastTrades:        return true
        case .getTradeVolume:       return true
        case .getAvailableBalances: return true
        case .newDepositAddress(_): return true
        case .withdrawCryptoFundsToWhitelistedAddress(_): return true
        case .heartbeat:            return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .symbols:              return .url
        case .ticker(_):            return .url
        case .currentOrderBook(_):  return .url
        case .tradeHistory(_):      return .url
        case .currentAuction(_):    return .url
        case .auctionHistory(_):    return .url
        case .newOrder:             return .url
        case .cancelOrder:          return .url
        case .cancelAllSessionOrders: return .url
        case .cancelAllActiveOrders: return .url
        case .orderStatus:          return .url
        case .getActiveOrders:      return .url
        case .getPastTrades:        return .url
        case .getTradeVolume:       return .url
        case .getAvailableBalances: return .url
        case .newDepositAddress(_): return .url
        case .withdrawCryptoFundsToWhitelistedAddress(_): return .url
        case .heartbeat:            return .url
            
        }
    }
    
    public var postData: [String: String] {
        switch self {
        case .symbols:              return [:]
        case .ticker(_):            return [:]
        case .currentOrderBook(_):  return [:]
        case .tradeHistory(_):      return [:]
        case .currentAuction(_):    return [:]
        case .auctionHistory(_):    return [:]
        case .newOrder:             return ["request": path]
        case .cancelOrder:          return ["request": path]
        case .cancelAllSessionOrders: return ["request": path]
        case .cancelAllActiveOrders: return ["request": path]
        case .orderStatus:          return ["request": path]
        case .getActiveOrders:      return ["request": path]
        case .getPastTrades(let currencyPair): return ["request": path, "symbol": currencyPair.displaySymbol]
        case .getTradeVolume:       return ["request": path]
        case .getAvailableBalances: return ["request": path]
        case .newDepositAddress(let currency): return ["request": "/v1/deposit/\(currency.code)/newAddress"]
        case .withdrawCryptoFundsToWhitelistedAddress(let currency): return ["request": "/v1/withdraw/\(currency.code)"]
        case .heartbeat:            return ["request": path]
        }
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .symbols:              return .aMonth
        case .ticker(_):            return .aMinute
        case .currentOrderBook(_):  return .aMinute
        case .tradeHistory(_):      return .aMinute
        case .currentAuction(_):    return .aMinute
        case .auctionHistory(_):    return .aMinute
            
        case .newOrder:             return .aMinute
        case .cancelOrder:          return .aMinute
        case .cancelAllSessionOrders: return .aMinute
        case .cancelAllActiveOrders: return .aMinute
        case .orderStatus:          return .aMinute
        case .getActiveOrders:      return .aMinute
        case .getPastTrades:        return .aMinute
        case .getTradeVolume:       return .aMinute
        case .getAvailableBalances: return .aMinute
        case .newDepositAddress(_): return .aMinute
        case .withdrawCryptoFundsToWhitelistedAddress(_): return .aMinute
        case .heartbeat:            return .aMinute
        }
    }
}

extension Gemini.Service: TickerServiceType, BalanceServiceType {
    public func getTickers(completion: @escaping (ResponseType) -> Void) {
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
    
    public func getBalances(completion: @escaping (ResponseType) -> Void) {
        
        getTickers(completion: { (_) in
            self.getAvailableBalances(completion: { (responseType) in
                completion(responseType)
            }, failure: nil)
        })
    }
    
    public func getPastTrades(completion: @escaping (CurrencyPair, ResponseType) -> Void, failure: @escaping (String?, String?) -> Void) {
        getSymbols(completion: { _ in
            self.store.symbolsResponse.symbols.forEach { symbol in
                self.getPastTrades(currencyPair: symbol, completion: completion, failure: failure)
            }
        })
    }
}
