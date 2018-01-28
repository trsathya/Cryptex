//
//  Poloniex.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation
import CryptoSwift

public extension CurrencyPair {
    
    var poloniexSymbol: String {
        get {
            return price.code + "_" + quantity.code
        }
    }
    
    public convenience init(poloniexSymbol: String, currencyStore: CurrencyStoreType) {
        let currencySymbols = poloniexSymbol.components(separatedBy: "_")
        let quantity = currencyStore.forCode(currencySymbols[1])
        let price = currencyStore.forCode(currencySymbols[0])
        self.init(quantity: quantity, price: price)
    }
}

public struct Poloniex {
    public class Ticker: Cryptex.Ticker {
        public let timestamp: Date
        
        public var id: Int?
        public var last = NSDecimalNumber.zero
        public var highestBid = NSDecimalNumber.zero
        public var lowestAsk = NSDecimalNumber.zero
        public var high24hr = NSDecimalNumber.zero
        public var low24hr = NSDecimalNumber.zero
        public var percentChange = NSDecimalNumber.zero
        public var quoteVolume = NSDecimalNumber.zero
        public var baseVolume = NSDecimalNumber.zero
        public var isFrozen: Bool?
        
        public init?(json: Any?, symbol: CurrencyPair, timestamp: Date) {
            self.timestamp = timestamp
            guard let json = json as? [String: Any] else { return nil }
            id = json["id"] as? Int
            last = NSDecimalNumber(json["last"])
            super.init(symbol: symbol, price: last)
            highestBid = NSDecimalNumber(json["highestBid"])
            lowestAsk = NSDecimalNumber(json["lowestAsk"])
            high24hr = NSDecimalNumber(json["high24hr"])
            low24hr = NSDecimalNumber(json["low24hr"])
            percentChange = NSDecimalNumber(json["percentChange"])
            quoteVolume = NSDecimalNumber(json["quoteVolume"])
            baseVolume = NSDecimalNumber(json["baseVolume"])
            isFrozen = json["isFrozen"] as? Bool
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
    
    public struct PastTrade {
        public var globalTradeID: UInt32
        public var tradeID: String
        public var date: Date = Date()
        public var rate: NSDecimalNumber
        public var amount: NSDecimalNumber
        public var total: NSDecimalNumber
        public var fee: NSDecimalNumber
        public var orderNumber: String
        public var type: TransactionType = .none
        public var category: String
        
        public init(json: [String: Any]) {
            globalTradeID = json["globalTradeID"] as! UInt32
            tradeID = json["tradeID"] as! String
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let string = json["date"] as? String, let value = df.date(from: string) {
                date = value
            }
            rate = NSDecimalNumber(json["rate"])
            amount = NSDecimalNumber(json["amount"])
            total = NSDecimalNumber(json["total"])
            fee = NSDecimalNumber(json["fee"])
            orderNumber = json["orderNumber"] as! String
            if let string = json["type"] as? String, let value = TransactionType(rawValue: string.lowercased()) {
                type = value
            }
            category = json["category"] as! String
        }
    }
    
    public struct FeeInfo {
        public var makerFee: NSDecimalNumber
        public var takerFee: NSDecimalNumber
        public var thirtyDayVolume: NSDecimalNumber
        public var nextTier: NSDecimalNumber
        
        public init(json: [String: Any]) {
            makerFee = NSDecimalNumber(json["makerFee"])
            takerFee = NSDecimalNumber(json["takerFee"])
            thirtyDayVolume = NSDecimalNumber(json["thirtyDayVolume"])
            nextTier = NSDecimalNumber(json["nextTier"])
        }
    }
    
    public struct Deposit {
        public var currency: Currency
        public var address: String
        public var amount: NSDecimalNumber
        public var confirmations: Int
        public var txid: String
        public var timestamp: Date
        public var status: String
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            currency = currencyStore.forCode(json["currency"] as? String ?? "")
            address = json["address"] as? String ?? ""
            amount = NSDecimalNumber(json["amount"])
            confirmations = json["confirmations"] as? Int ?? 0
            txid = json["txid"] as? String ?? ""
            timestamp = Date(timeIntervalSince1970: json["timestamp"] as? TimeInterval ?? 0)
            status = json["status"] as? String ?? ""
        }
    }
    
    public struct Withdrawal {
        public var withdrawalNumber: Int
        public var currency: Currency
        public var address: String
        public var amount: NSDecimalNumber
        public var timestamp: Date
        public var status: String
        public var ipAddress: String
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            withdrawalNumber = json["withdrawalNumber"] as? Int ?? 0
            currency = currencyStore.forCode(json["currency"] as? String ?? "")
            address = json["address"] as? String ?? ""
            amount = NSDecimalNumber(json["amount"])
            timestamp = Date(timeIntervalSince1970: json["timestamp"] as? TimeInterval ?? 0)
            status = json["status"] as? String ?? ""
            ipAddress = json["ipAddress"] as? String ?? ""
        }
    }
    
    public class Store: ExchangeDataStore<Poloniex.Ticker, Balance> {
        
        override fileprivate init() {
            super.init()
            name = "Poloniex"
            accountingCurrency = .USDT
        }
        
        public var tickerResponse: HTTPURLResponse? = nil
        public var balanceResponse: HTTPURLResponse? = nil
        public var feeInfoResponse: (response: HTTPURLResponse?, feeInfo: Poloniex.FeeInfo?) = (nil, nil)
        public var pastTradesResponse: (response: HTTPURLResponse?, pastTrades: [String: [Poloniex.PastTrade]]) = (nil, [:])
        public var depositsWithdrawalsResponse: (response: HTTPURLResponse?, deposits: [Poloniex.Deposit], withdrawals: [Poloniex.Withdrawal]) = (nil, [], [])
    }
    
    public class Service: Network, TickerServiceType {
        
        public let store = Store()
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            
            let apiType = Poloniex.PublicAPI.returnTicker
            
            if apiType.checkInterval(response: store.tickerResponse) {
                completion(.cached)
            } else {
                poloniexDataTaskFor(api: apiType) { (response) in
                    
                    guard let json = response.json as? [String: Any] else { return }
                    
                    var date = Date()
                    if let dateString = response.httpResponse?.allHeaderFields["Date"] as? String, let parsedDate = DateFormatter.httpHeader.date(from: dateString) {
                        date = parsedDate
                    }
                    let tickers = json.flatMap { Poloniex.Ticker(json: $0.value, symbol: CurrencyPair(poloniexSymbol: $0.key, currencyStore: self), timestamp: date) }
                    self.store.setTickersInDictionary(tickers: tickers)
                    
                    self.store.tickerResponse = response.httpResponse
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func returnBalances(completion: @escaping (ResponseType) -> Void) {
            
            let apiType = Poloniex.PrivateAPI.returnBalances
            
            if apiType.checkInterval(response: store.balanceResponse) {
                completion(.cached)
            } else {
                poloniexDataTaskFor(api: apiType) { (response) in
                    
                    guard let dictionary = response.json as? [String: String] else {
                        completion(.unexpected(response))
                        return
                    }
                    
                    let filtered = dictionary.filter {$1 != "0.00000000"}
                    
                    var balances: [Balance] = []
                    filtered.forEach { (arg) in
                        let (key, value) = arg
                        balances.append(Balance(currency: self.forCode(key), quantity: NSDecimalNumber(string: value)))
                    }
                    self.store.balances = balances
                    self.store.balanceResponse = response.httpResponse
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func returnTradeHistory(currencyPairSymbol: String?, start: Date, end: Date, completion: @escaping (ResponseType) -> Void) {
            
            let apiType = Poloniex.PrivateAPI.returnTradeHistory(currencyPairSymbol, start, end)
            
            if apiType.checkInterval(response: store.pastTradesResponse.response) {
                completion(.cached)
            } else {
                poloniexDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [String: [[String: Any]]] else {
                        print("Error: Cast Failed in \(#function)")
                        return
                    }
                    var trades: [String: [Poloniex.PastTrade]] = [:]
                    json.forEach { key, value in
                        let currencyPair = CurrencyPair(poloniexSymbol: key, currencyStore: self)
                        var tradesArray: [Poloniex.PastTrade] = []
                        value.forEach { tradeJson in
                            tradesArray.append(Poloniex.PastTrade(json: tradeJson))
                        }
                        trades[currencyPair.displaySymbol] = tradesArray
                    }
                    self.store.pastTradesResponse = (response.httpResponse, trades)
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func returnFeeInfo(completion: @escaping (ResponseType) -> Void) {
            
            let apiType = Poloniex.PrivateAPI.returnFeeInfo
            
            if apiType.checkInterval(response: store.feeInfoResponse.response) {
                completion(.cached)
            } else {
                poloniexDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [String: Any] else {
                        completion(.unexpected(response))
                        return
                    }
                    self.store.feeInfoResponse = (response.httpResponse, Poloniex.FeeInfo(json: json))
                    completion(.fetched)
                    }.resume()
            }
        }
        
        public func returnDepositsWithdrawals(start: Date, end: Date, completion: @escaping (ResponseType) -> Void) {
            let apiType = Poloniex.PrivateAPI.returnDepositsWithdrawals(start, end)
            
            poloniexDataTaskFor(api: apiType) { (response) in
                
                guard let json = response.json as? [String: Any] else {
                    completion(.unexpected(response))
                    return
                }
                var deposits: [Poloniex.Deposit] = []
                if let array = json["deposits"] as? [[String: Any]] {
                    deposits = array.flatMap { item -> Poloniex.Deposit? in
                        return Poloniex.Deposit(json: item, currencyStore: self)
                    }
                }
                var withdrawals: [Poloniex.Withdrawal] = []
                if let array = json["withdrawals"] as? [[String: Any]] {
                    withdrawals = array.flatMap { item -> Poloniex.Withdrawal? in
                        return Poloniex.Withdrawal(json: item, currencyStore: self)
                    }
                }
                
                self.store.depositsWithdrawalsResponse = (response.httpResponse, deposits, withdrawals)
                completion(.fetched)
                }.resume()
        }
        
        public func returnAvailableAccountBalances() {
            
            let apiType = Poloniex.PrivateAPI.returnAvailableAccountBalances
            
            poloniexDataTaskFor(api: apiType) { (response) in
                
                }.resume()
        }
        
        func poloniexDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                
                if let json = response.json as? [String: String], let error = json["error"] {
                    
                    if let startRange = error.range(of: "Nonce must be greater than "), let endRange = error.range(of: ". You provided "), self.isMock == false {
                        let nonce = Int(error[startRange.upperBound..<endRange.lowerBound])
                        print("Setting nonce \(nonce ?? 0) from api error")
                    }
                    print("Poloniex error: %@", error)
                }
                completion?(response)
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            
            if let key = key, let secret = secret, api.authenticated {
                
                var postDataDictionary = api.postData
                postDataDictionary["nonce"] = "\(getTimestampInSeconds())"
                
                var postDataString = postDataDictionary.queryString
                
                if HttpMethod.POST == api.httpMethod {
                    mutableURLRequest.httpBody = postDataString.utf8Data()
                }
                api.print("Request Data: \(postDataString)", content: .response)
                
                do {
                    let hmac_sha = try HMAC(key: secret, variant: .sha512).authenticate(Array(postDataString.utf8))
                    mutableURLRequest.setValue(hmac_sha.toHexString(), forHTTPHeaderField: "Sign")
                } catch {
                    print(error)
                }
                
                mutableURLRequest.setValue(key, forHTTPHeaderField: "Key")
            }
            
            return mutableURLRequest
        }
    }
    
    public enum PublicAPI {
        case returnTicker
        case return24Volume
        case returnOrderBook(CurrencyPair)
        case returnCurrencies
        case returnLoanOrders(Currency)
    }
    
    public enum PrivateAPI {
        case returnBalances
        case returnCompleteBalances
        case returnDepositAddresses
        case generateNewAddress
        case returnDepositsWithdrawals(Date, Date)
        case returnOpenOrders
        case returnTradeHistory(String?, Date, Date) // CurrencyPair or all
        case returnOrderTrades
        case buy
        case sell
        case cancelOrder
        case moveOrder
        case withdraw
        case returnFeeInfo
        case returnAvailableAccountBalances
        case returnTradableBalances
        case transferBalance
        case returnMarginAccountSummary
        case marginBuy
        case marginSell
        case getMarginPosition
        case closeMarginPosition
        case createLoanOffer
        case cancelLoanOffer
        case returnOpenLoanOffers
        case returnActiveLoans
        case returnLendingHistory
        case toggleAutoRenew
    }
}

extension Poloniex.PublicAPI: APIType {
    
    public var host: String {
        return "https://poloniex.com"
    }
    
    public var path: String {
        switch self {
        case .returnTicker:
            return "/public?command=returnTicker"
        case .return24Volume:
            return "/public?command=return24hVolume"
        case .returnOrderBook(let currencyPair):
            return "/public?command=returnOrderBook&currencyPair=\(currencyPair.poloniexSymbol)&depth=10"
        case .returnCurrencies:
            return "/public?command=returnCurrencies"
        case .returnLoanOrders(let currency):
            return "/public?command=returnLoanOrders&currency=\(currency.code)"
        }
    }
    
    public var httpMethod: HttpMethod {
        return .GET
    }
    
    public var authenticated: Bool {
        return false
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .returnTicker:                 return .url
        case .return24Volume:               return .url
        case .returnOrderBook(_):           return .url
        case .returnCurrencies:             return .url
        case .returnLoanOrders(_):          return .url
        }
    }
    
    public var postData: [String: String] {
        return [:]
    }
    
    public var refetchInterval: TimeInterval {
        return .aMinute
    }
}

extension Poloniex.PrivateAPI: APIType {
    
    public var host: String {
        return "https://poloniex.com"
    }
    
    public var path: String {
        return "/tradingApi"
    }
    
    public var httpMethod: HttpMethod {
        return .POST
    }
    
    public var authenticated: Bool {
        return true
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .returnBalances: return .url
        case .returnCompleteBalances: return .url
        case .returnDepositAddresses: return .url
        case .generateNewAddress: return .url
        case .returnDepositsWithdrawals(_, _): return .url
        case .returnOpenOrders: return .url
        case .returnTradeHistory(_, _, _): return .url
        case .returnOrderTrades: return .url
        case .buy: return .url
        case .sell: return .url
        case .cancelOrder: return .url
        case .moveOrder: return .url
        case .withdraw: return .url
        case .returnFeeInfo: return .url
        case .returnAvailableAccountBalances: return .url
        case .returnTradableBalances: return .url
        case .transferBalance: return .url
        case .returnMarginAccountSummary: return .url
        case .marginBuy: return .url
        case .marginSell: return .url
        case .getMarginPosition: return .url
        case .closeMarginPosition: return .url
        case .createLoanOffer: return .url
        case .cancelLoanOffer: return .url
        case .returnOpenLoanOffers: return .url
        case .returnActiveLoans: return .url
        case .returnLendingHistory: return .url
        case .toggleAutoRenew: return .url
        }
    }
    
    public var postData: [String: String] {
        switch self {
        case .returnBalances: return ["command": "returnBalances"]
        case .returnCompleteBalances: return ["command": "returnCompleteBalances"]
        case .returnDepositAddresses: return ["command": "returnDepositAddresses"]
        case .generateNewAddress: return ["command": "generateNewAddress"]
        case .returnDepositsWithdrawals(let start, let end):
            return ["command": "returnDepositsWithdrawals", "start": "\(start.timeIntervalSince1970)", "end": "\(end.timeIntervalSince1970)"]
        case .returnOpenOrders: return ["command": "returnOpenOrders"]
        case .returnTradeHistory(let currencyPair, let start, let end):
            var data = ["command": "returnTradeHistory"]
            if let currencyPair = currencyPair {
                data["currencyPair"] = currencyPair
            } else {
                data["currencyPair"] = "all"
            }
            data["start"] = "\(start.timeIntervalSince1970)"
            data["end"] = "\(end.timeIntervalSince1970)"
            return data
        case .returnOrderTrades: return ["command": "returnOrderTrades"]
        case .buy: return ["command": "buy"]
        case .sell: return ["command": "sell"]
        case .cancelOrder: return ["command": "cancelOrder"]
        case .moveOrder: return ["command": "moveOrder"]
        case .withdraw: return ["command": "withdraw"]
        case .returnFeeInfo: return ["command": "returnFeeInfo"]
        case .returnAvailableAccountBalances: return ["command": "returnAvailableAccountBalances"]
        case .returnTradableBalances: return ["command": "returnTradableBalances"]
        case .transferBalance: return ["command": "transferBalance"]
        case .returnMarginAccountSummary: return ["command": "returnMarginAccountSummary"]
        case .marginBuy: return ["command": "marginBuy"]
        case .marginSell: return ["command": "marginSell"]
        case .getMarginPosition: return ["command": "getMarginPosition"]
        case .closeMarginPosition: return ["command": "closeMarginPosition"]
        case .createLoanOffer: return ["command": "createLoanOffer"]
        case .cancelLoanOffer: return ["command": "cancelLoanOffer"]
        case .returnOpenLoanOffers: return ["command": "returnOpenLoanOffers"]
        case .returnActiveLoans: return ["command": "returnActiveLoans"]
        case .returnLendingHistory: return ["command": "returnLendingHistory"]
        case .toggleAutoRenew: return ["command": "toggleAutoRenew"]
        }
    }
    
    public var refetchInterval: TimeInterval {
        return .aMinute
    }
}

extension Poloniex.Service: BalanceServiceType {
    
    public func getBalances(completion: @escaping (ResponseType) -> Void) {
        
        getTickers(completion: { _ in
            self.returnBalances(completion: { responseType in
                completion(responseType)
            })
        })
    }
    
    public func returnTradeHistory(start: Date, end: Date, completion: @escaping (ResponseType) -> Void, captcha: ((String) -> Void)?) {
        getTickers(completion: { _ in
            self.returnTradeHistory(currencyPairSymbol: nil, start: start, end: end, completion: completion)
        })
    }
}
