//
//  Kraken.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Kraken {
    
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
            name = "Kraken"
            accountingCurrency = .USD
        }
        
        public var symbolsResponse: (response: HTTPURLResponse?, symbols: [CurrencyPair]) = (nil, [])
        public var tickerResponse: [String: HTTPURLResponse] = [:]
        public var balanceResponse: HTTPURLResponse? = nil
        public var accountFeesResponse: HTTPURLResponse? = nil
    }
    
    public enum API {
        case getServerTime
        case getAssetInfo
        case getTradableAssetPairs
        case getTickerInformation(String)
        case getOHLCData
        case getOrderBook
        case getRecentTrades
        case getRecentSpreadData
        // private
        case getAccountBalance
        case getTradeBalance
        case getOpenOrders
        case getClosedOrders
        case queryOrdersInfo
        case getTradesHistory
        case queryTradesInfo
        case getOpenPositions
        case getLedgersInfo
        case queryLedgers
        case getTradeVolume
        case addStandardOrder
        case cancelOpenOrder
        case getDepositMethods
        case getDepositAddresses
        case getStatusOfRecentDeposits
        case getWithdrawalInformation
        case withdrawFunds
        case getStatusOfRecentWithdrawals
        case requestWithdrawalCancelation
    }
    
    public class Service: Network {
        
        public let store = Store()
        
        public func getSymbols(completion: @escaping (ResponseType) -> Void) {
            let apiType = Kraken.API.getAssetInfo
            if apiType.checkInterval(response: store.symbolsResponse.response) {
                completion(.cached)
            } else {
                krakenDataTaskFor(api: apiType, completion: { (response) in
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
            let apiType = Kraken.API.getTickerInformation(symbol.displaySymbol)
            if apiType.checkInterval(response: store.tickerResponse[symbol.displaySymbol]) {
                completion(symbol, .cached)
            } else {
                krakenDataTaskFor(api: apiType, completion: { (response) in
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
            let apiType = Kraken.API.getAccountBalance
            if apiType.checkInterval(response: store.balanceResponse) {
                completion(.cached)
            } else {
                krakenDataTaskFor(api: apiType) { (response) in
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
        
        private func krakenDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                // Handle error here
                completion?(response)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if let key = key, let secret = secret, api.authenticated {
                
                var postDataDictionary = api.postData
                
                let nonce = "\(getTimestampInSeconds())"
                postDataDictionary["nonce"] = nonce
                //postDataDictionary?["otp"] = "123456"
                
                let postDataString = postDataDictionary.queryString
                
                // POST payload
                if case .POST = api.httpMethod {
                    mutableURLRequest.httpBody = postDataString.utf8Data()
                }
                
                api.print("Request Data: \(postDataString)", content: .response)
                
                let prehashBytes = Array(api.path.utf8) + SHA2(variant: .sha256).calculate(for: Array((nonce + postDataString).utf8))
                if let bytes = Data(base64Encoded: secret)?.bytes,
                    let hmac_sha = try? HMAC(key: bytes, variant: .sha512).authenticate(prehashBytes),
                    let signature = hmac_sha.toBase64()
                {
                    mutableURLRequest.setValue(signature, forHTTPHeaderField: "API-SIGN")
                }
                
                mutableURLRequest.setValue(key, forHTTPHeaderField: "API-KEY")            }
            
            return mutableURLRequest
        }
    }
}

extension Kraken.API: APIType {
    public var host: String {
        return "https://api.kraken.com"
    }

    public var path: String {
        switch self {
        case .getServerTime:            return "/0/public/Time"
        case .getAssetInfo:             return "/0/public/Assets"
        case .getTradableAssetPairs:    return "/0/public/AssetPairs"
        case .getTickerInformation(_):  return "/0/public/Ticker"
        case .getOHLCData:              return "/0/public/OHLC"
        case .getOrderBook:             return "/0/public/Depth"
        case .getRecentTrades:          return "/0/public/Trades"
        case .getRecentSpreadData:      return "/0/public/Spread"
        // private
        case .getAccountBalance:            return "/0/private/Balance"
        case .getTradeBalance:              return "/0/private/TradeBalance"
        case .getOpenOrders:                return "/0/private/OpenOrders"
        case .getClosedOrders:              return "/0/private/ClosedOrders"
        case .queryOrdersInfo:              return "/0/private/QueryOrders"
        case .getTradesHistory:             return "/0/private/TradesHistory"
        case .queryTradesInfo:              return "/0/private/QueryTrades"
        case .getOpenPositions:             return "/0/private/OpenPositions"
        case .getLedgersInfo:               return "/0/private/Ledgers"
        case .queryLedgers:                 return "/0/private/QueryLedgers"
        case .getTradeVolume:               return "/0/private/TradeVolume"
        case .addStandardOrder:             return "/0/private/AddOrder"
        case .cancelOpenOrder:              return "/0/private/CancelOrder"
        case .getDepositMethods:            return "/0/private/DepositMethods"
        case .getDepositAddresses:          return "/0/private/DepositAddresses"
        case .getStatusOfRecentDeposits:    return "/0/private/DepositStatus"
        case .getWithdrawalInformation:     return "/0/private/WithdrawInfo"
        case .withdrawFunds:                return "/0/private/Withdraw"
        case .getStatusOfRecentWithdrawals: return "/0/private/WithdrawStatus"
        case .requestWithdrawalCancelation: return "/0/private/WithdrawCancel"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .getServerTime:            return .GET
        case .getAssetInfo:             return .GET
        case .getTradableAssetPairs:    return .GET
        case .getTickerInformation(_):  return .GET
        case .getOHLCData:              return .GET
        case .getOrderBook:             return .GET
        case .getRecentTrades:          return .GET
        case .getRecentSpreadData:      return .GET
        case .getAccountBalance:            return .POST
        case .getTradeBalance:              return .POST
        case .getOpenOrders:                return .POST
        case .getClosedOrders:              return .POST
        case .queryOrdersInfo:              return .POST
        case .getTradesHistory:             return .POST
        case .queryTradesInfo:              return .POST
        case .getOpenPositions:             return .POST
        case .getLedgersInfo:               return .POST
        case .queryLedgers:                 return .POST
        case .getTradeVolume:               return .POST
        case .addStandardOrder:             return .POST
        case .cancelOpenOrder:              return .POST
        case .getDepositMethods:            return .POST
        case .getDepositAddresses:          return .POST
        case .getStatusOfRecentDeposits:    return .POST
        case .getWithdrawalInformation:     return .POST
        case .withdrawFunds:                return .POST
        case .getStatusOfRecentWithdrawals: return .POST
        case .requestWithdrawalCancelation: return .POST
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .getServerTime:            return false
        case .getAssetInfo:             return false
        case .getTradableAssetPairs:    return false
        case .getTickerInformation(_):  return false
        case .getOHLCData:              return false
        case .getOrderBook:             return false
        case .getRecentTrades:          return false
        case .getRecentSpreadData:      return false
        case .getAccountBalance:            return true
        case .getTradeBalance:              return true
        case .getOpenOrders:                return true
        case .getClosedOrders:              return true
        case .queryOrdersInfo:              return true
        case .getTradesHistory:             return true
        case .queryTradesInfo:              return true
        case .getOpenPositions:             return true
        case .getLedgersInfo:               return true
        case .queryLedgers:                 return true
        case .getTradeVolume:               return true
        case .addStandardOrder:             return true
        case .cancelOpenOrder:              return true
        case .getDepositMethods:            return true
        case .getDepositAddresses:          return true
        case .getStatusOfRecentDeposits:    return true
        case .getWithdrawalInformation:     return true
        case .withdrawFunds:                return true
        case .getStatusOfRecentWithdrawals: return true
        case .requestWithdrawalCancelation: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        return .response
    }
    
    public var postData: [String: String] {
        return [:]
    }
    
    public var refetchInterval: TimeInterval {
        return .aMinute
    }
}

extension Kraken.Service: TickerServiceType, BalanceServiceType {
    
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
