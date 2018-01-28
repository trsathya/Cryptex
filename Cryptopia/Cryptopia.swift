//
//  Cryptopia.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/2/18.
//

import Foundation
import CryptoSwift

extension CurrencyPair {
    
    var cryptopiaLabel: String {
        return quantity.code + "/" + price.code
    }
    
    convenience init(cryptopiaLabel: String, currencyStore: CurrencyStoreType) {
        let currencySymbols = cryptopiaLabel.components(separatedBy: "/")
        let quantity = currencyStore.forCode(currencySymbols[0])
        let price = currencyStore.forCode(currencySymbols[1])
        self.init(quantity: quantity, price: price)
    }
}

public struct Cryptopia {
    
    public class Market: Ticker {
        public var tradePairId: Int = 0
        public var label: String = ""
        public var askPrice = NSDecimalNumber.zero
        public var bidPrice = NSDecimalNumber.zero
        public var low = NSDecimalNumber.zero
        public var high = NSDecimalNumber.zero
        public var volume = NSDecimalNumber.zero
        public var lastPrice = NSDecimalNumber.zero
        public var buyVolume = NSDecimalNumber.zero
        public var sellVolume = NSDecimalNumber.zero
        public var change = NSDecimalNumber.zero
        public var open = NSDecimalNumber.zero
        public var close = NSDecimalNumber.zero
        public var baseVolume = NSDecimalNumber.zero
        public var baseBuyVolume = NSDecimalNumber.zero
        public var baseSellVolume = NSDecimalNumber.zero
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            tradePairId = json["TradePairId"] as? Int ?? 0
            label = json["Label"] as? String ?? ""
            askPrice = NSDecimalNumber(json["AskPrice"])
            bidPrice = NSDecimalNumber(json["BidPrice"])
            low = NSDecimalNumber(json["Low"])
            high = NSDecimalNumber(json["High"])
            volume = NSDecimalNumber(json["Volume"])
            lastPrice = NSDecimalNumber(json["LastPrice"])
            buyVolume = NSDecimalNumber(json["BuyVolume"])
            sellVolume = NSDecimalNumber(json["SellVolume"])
            change = NSDecimalNumber(json["Change"])
            open = NSDecimalNumber(json["Open"])
            close = NSDecimalNumber(json["Close"])
            baseVolume = NSDecimalNumber(json["BaseVolume"])
            baseBuyVolume = NSDecimalNumber(json["BaseBuyVolume"])
            baseSellVolume = NSDecimalNumber(json["BaseSellVolume"])
            super.init(symbol: CurrencyPair(cryptopiaLabel: label, currencyStore: currencyStore), price: lastPrice)
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
        public var currencyId: Int = 0
        public var symbol: String = ""
        public var total = NSDecimalNumber.zero
        public var available = NSDecimalNumber.zero
        public var unconfirmed = NSDecimalNumber.zero
        public var heldForTrades = NSDecimalNumber.zero
        public var pendingWithdraw = NSDecimalNumber.zero
        public var address: String = ""
        public var baseAddress: String = ""
        public var status: String = ""
        public var statusMessage: String = ""
        
        public init(json: [String: Any], currencyStore: CurrencyStoreType) {
            currencyId = json["CurrencyId"] as? Int ?? 0
            symbol = json["Symbol"] as? String ?? ""
            total = NSDecimalNumber(json["Total"])
            available = NSDecimalNumber(json["Available"])
            unconfirmed = NSDecimalNumber(json["Unconfirmed"])
            heldForTrades = NSDecimalNumber(json["HeldForTrades"])
            pendingWithdraw = NSDecimalNumber(json["PendingWithdraw"])
            address = json["Address"] as? String ?? ""
            baseAddress = json["BaseAddress"] as? String ?? ""
            status = json["Status"] as? String ?? ""
            statusMessage = json["StatusMessage"] as? String ?? ""
            super.init(currency: currencyStore.forCode(symbol), quantity: total)
        }
    }
    
    public class CryptopiaCurrency: Currency {
        public var id: Int
        public var symbol: String
        public var algorithm: String
        public var withdrawFee: NSDecimalNumber
        public var minWithdraw: NSDecimalNumber
        public var minBaseTrade: NSDecimalNumber
        public var isTipEnabled: Bool
        public var minTip: NSDecimalNumber
        public var depositConfirmations: Int
        public var status: String
        public var statusMessage: String
        public var listingStatus: String
        
        public init(json: [String: Any]) {
            id = json["Id"] as? Int ?? 0
            symbol = json["Symbol"] as? String ?? ""
            algorithm = json["Algorithm"] as? String ?? ""
            withdrawFee = NSDecimalNumber(json["WithdrawFee"])
            minWithdraw = NSDecimalNumber(json["MinWithdraw"])
            minBaseTrade = NSDecimalNumber(json["MinBaseTrade"])
            isTipEnabled = json["IsTipEnabled"] as? Bool ?? false
            minTip = NSDecimalNumber(json["MinTip"])
            depositConfirmations = json["DepositConfirmations"] as? Int ?? 0
            status = json["Status"] as? String ?? ""
            statusMessage = json["StatusMessage"] as? String ?? ""
            listingStatus = json["ListingStatus"] as? String ?? ""
            super.init(name: json["Name"] as? String ?? "", code: symbol)
        }
    }
    
    public struct TradePair {
        public let id: Int
        public let label: String
        public let curency: String
        public let symbol: String
        public let baseCurrency: String
        public let baseSymbol: String
        public let status: String
        public let statusMessage: String
        public let tradeFee: NSDecimalNumber
        public let minimumTrade: NSDecimalNumber
        public let maximumTrade: NSDecimalNumber
        public let minimumBaseTrade: NSDecimalNumber
        public let maximumBaseTrade : NSDecimalNumber
        public let minimumPrice : NSDecimalNumber
        public let maximumPrice : NSDecimalNumber
    }
    
    public enum API {
        case getMarkets
        case getBalance
        //
        case getCurrencies
        case getTradePairs
    }
    
    public class Store: ExchangeDataStore<Market, Balance> {
        
        override fileprivate init() {
            super.init()
            name = "Cryptopia"
            accountingCurrency = .USDT
        }
        
        public var tickersResponse: HTTPURLResponse? = nil
        public var balanceResponse: HTTPURLResponse? = nil
        public var currenciesResponse: (response: HTTPURLResponse?, currencies: [CryptopiaCurrency]) = (nil, [])
    }

    class CurrencyStore: CurrencyStoreType {
        
        let currencies: [CryptopiaCurrency]
        
        init(currencies: [CryptopiaCurrency]) {
            self.currencies = currencies
        }
        
        func isKnown(code: String) -> Bool {
            return currencies.filter { $0.code.lowercased() == code.lowercased() }.count > 0
        }
        
        func forCode(_ code: String) -> Currency {
            if let currency = (currencies.filter { $0.code.lowercased() == code.lowercased() }).first {
                return currency
            } else {
                return Currency(name: code, code: code)
            }
        }
    }
    
    public class Service: Network, TickerServiceType, BalanceServiceType {
        public let store = Store()
        
        public func getTickers(completion: @escaping (ResponseType) -> Void) {
            let apiType = Cryptopia.API.getMarkets
            if apiType.checkInterval(response: store.tickersResponse) {
                completion(.cached)
            } else {
                cryptopiaDataTaskFor(api: apiType) { (response) in
                    guard let tickerArray = response.json as? [[String: Any]] else { return }
                    var tickers: [Market] = []
                    for ticker in tickerArray {
                        let ticker = Market(json: ticker, currencyStore: self)
                        tickers.append(ticker)
                    }
                    self.store.setTickersInDictionary(tickers: tickers)
                    
                    self.store.tickersResponse = response.httpResponse
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        public func getBalances(completion: @escaping (ResponseType) -> Void) {
            let apiType = Cryptopia.API.getBalance
            
            if apiType.checkInterval(response: store.balanceResponse) {
                
                completion(.cached)
                
            } else {
                
                cryptopiaDataTaskFor(api: apiType) { (response) in
                    
                    guard let json = response.json as? [[String: Any]] else { return }
                    let balances = json.map { Balance(json: $0, currencyStore: self) }.filter { $0.available != .zero }
                    self.store.balances = balances
                    self.store.balanceResponse = response.httpResponse
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        public func getCurrencies(completion: @escaping (ResponseType) -> Void) {
            let apiType = Cryptopia.API.getCurrencies
            
            if apiType.checkInterval(response: store.currenciesResponse.response) {
                completion(.cached)
            } else {
                cryptopiaDataTaskFor(api: apiType) { (response) in
                    guard let json = response.json as? [[String: Any]] else { return }
                    let currencies = json.map { CryptopiaCurrency(json: $0) }
                    
                    self.store.currenciesResponse = (response.httpResponse, currencies)
                    self.apiCurrencyOverrides = Currency.dictionary(array: currencies)
                    completion(.fetched)
                    
                    }.resume()
            }
        }
        
        func cryptopiaDataTaskFor(api: APIType, completion: ((Response) -> Void)?) -> URLSessionDataTask {
            return dataTaskFor(api: api) { (response) in
                guard let json = response.json as? [String: Any] else { return }
                if let success = json["Success"] as? Bool, let jsonData = json["Data"], success == true {
                    var tempResponse = response
                    tempResponse.json = jsonData
                    completion?(tempResponse)
                } else {
                    // Handle error here
                    if let message = json["Message"] {
                        api.print(message, content: .response)
                    }
                    if let apiError = json["Error"] {
                        api.print(apiError, content: .response)
                    }
                }
            }
        }
        
        public override func requestFor(api: APIType) -> NSMutableURLRequest {
            let mutableURLRequest = api.mutableRequest
            if let key = key, let secret = secret, api.authenticated {
                if let url = mutableURLRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed),
                    let data = api.postData.data, let string = data.string {
                    api.print("Request Data: \(string)", content: .response)
                    // POST payload
                    if case .POST = api.httpMethod {
                        mutableURLRequest.httpBody = data
                    }
                    let nonce = "\(Date().timeIntervalSince1970)"
                    let prehash = key + api.httpMethod.rawValue + url.lowercased() + nonce + data.md5().base64EncodedString()
                    if let bytes = Data(base64Encoded: secret)?.bytes, let hmac_sha256 = try? HMAC(key: bytes, variant: .sha256).authenticate(Array(prehash.utf8)) {
                        let authHeader = "amx " + key + ":" + Data(bytes: hmac_sha256).base64EncodedString() + ":" + nonce
                        mutableURLRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
                    }
                }
            }
            return mutableURLRequest
        }
    }
}

extension Cryptopia.API: APIType {
    public var host: String {
        return "https://www.cryptopia.co.nz/api"
    }
    
    public var path: String {
        switch self {
        case .getCurrencies: return "/GetCurrencies"
        case .getTradePairs: return "/GetTradePairs"
        case .getMarkets: return "/GetMarkets"
        case .getBalance: return "/GetBalance"
        }
    }
    
    public var httpMethod: HttpMethod {
        switch self {
        case .getCurrencies: return .GET
        case .getTradePairs: return .GET
        case .getMarkets: return .GET
        case .getBalance: return .POST
        }
    }
    
    public var authenticated: Bool {
        switch self {
        case .getCurrencies: return false
        case .getTradePairs: return false
        case .getMarkets: return false
        case .getBalance: return true
        }
    }
    
    public var loggingEnabled: LogLevel {
        switch self {
        case .getCurrencies: return .url
        case .getTradePairs: return .url
        case .getMarkets: return .url
        case .getBalance: return .url
        }
    }
    
    public var postData: [String : String] {
        switch self {
        case .getCurrencies: return [:]
        case .getTradePairs: return [:]
        case .getMarkets: return [:]
        case .getBalance: return [:]
        }
    }
    
    public var refetchInterval: TimeInterval {
        switch self {
        case .getCurrencies: return .aMonth
        case .getTradePairs: return .aMonth
        case .getMarkets: return .aMinute
        case .getBalance: return .aMinute
        }
    }
}
