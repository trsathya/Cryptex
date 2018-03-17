//
//  Services.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import Foundation

class Services {
    static let shared = Services()
    
    private init() { }
    
    lazy var coinMarketCap: CoinMarketCap.Service = {
        return CoinMarketCap.Service(key: nil, secret: nil, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
    }()
    
    lazy var gemini: Gemini.Service = {
        return Gemini.Service(key: API.Gemini.key, secret: API.Gemini.secret, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
    }()
    
    lazy var poloniex: Poloniex.Service = {
        return Poloniex.Service(key: API.Poloniex.key, secret: API.Poloniex.secret, session: URLSession.shared, userPreference: .USDT_BTC, currencyOverrides: nil)
    }()
    
    lazy var gdax: GDAX.Service = {
        let userPreference = UserPreference(fiat: .USD, crypto: .Bitcoin, ignoredFiats: [.EUR, .GBP])
        return GDAX.Service(key: API.GDAX.key, secret: API.GDAX.secret, passphrase: API.GDAX.passphrase, session: URLSession.shared, userPreference: userPreference, currencyOverrides: nil)
    }()
    
    lazy var binance: Binance.Service = {
        return Binance.Service(key: API.Binance.key, secret: API.Binance.secret, session: URLSession.shared, userPreference: .USDT_BTC, currencyOverrides: ["BCC": Currency(name: "Bitcoin Cash", code: "BCC")])
    }()
    
    lazy var cryptopia: Cryptopia.Service = {
        return Cryptopia.Service(key: API.Cryptopia.key, secret: API.Cryptopia.secret, session: URLSession.shared, userPreference: .USDT_BTC, currencyOverrides: nil)
    }()

    lazy var bitGrail: BitGrail.Service = {
        return BitGrail.Service(key: API.Binance.key, secret: API.Binance.secret, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
    }()

    lazy var coinExchange: CoinExchange.Service = {
        let userPreference = UserPreference(fiat: .USDT, crypto: .Bitcoin, ignoredFiats: [.EUR])
        return CoinExchange.Service(key: nil, secret: nil, session: URLSession.shared, userPreference: userPreference, currencyOverrides: nil)
    }()
    
    lazy var bitfinex: Bitfinex.Service = {
        return Bitfinex.Service(key: API.Bitfinex.key, secret: API.Bitfinex.secret, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
    }()
    
    lazy var koinex: Koinex.Service = {
        let userPreference = UserPreference(fiat: .INR, crypto: .Bitcoin, ignoredFiats: [])
        return Koinex.Service(key: nil, secret: nil, session: URLSession.shared, userPreference: userPreference, currencyOverrides: nil)
    }()
    
    lazy var kraken: Kraken.Service = {
        return Kraken.Service(key: API.Kraken.key, secret: API.Kraken.secret, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
    }()
    
/*    lazy var kuCoin: KuCoin.Service = {
        return KuCoin.Service(key: API.KuCoin.key, secret: API.KuCoin.secret, session: URLSession.shared, userPreference: .USDT_BTC, currencyOverrides: nil)
    }()*/

    
    func balance() -> NSDecimalNumber {
        
        var totalBalance = NSDecimalNumber.zero
        
        totalBalance = totalBalance.adding(gemini.store.getTotalBalance())
        totalBalance = totalBalance.adding(poloniex.store.getTotalBalance())
        totalBalance = totalBalance.adding(gdax.store.getTotalBalance())
        totalBalance = totalBalance.adding(binance.store.getTotalBalance())
        totalBalance = totalBalance.adding(cryptopia.store.getTotalBalance())
        if let btcPrice = gemini.store.tickersDictionary["BTCUSD"]?.price {
            let xrbValueInUSD = btcPrice.multiplying(by: bitGrail.store.getTotalBalance())
            totalBalance = totalBalance.adding(xrbValueInUSD)
        }
        return totalBalance
    }
    
    func fetchAllBalances(completion: (() -> Void)?, failure: ((String?, String?) -> Void)?, captcha: ((String) -> Void)?) {
        coinMarketCap.getGlobal { (_) in
            completion?()
        }
        gemini.getBalances(completion: { _ in
            completion?()
        })
        poloniex.getBalances(completion: { (_) in
            completion?()
        })
        gdax.getBalances(completion: { (_) in
            completion?()
        })
        binance.getBalances(completion: { (_) in
            completion?()
        })
        cryptopia.getCurrencies { (_) in
            self.cryptopia.getTickers { (_) in
                self.cryptopia.getBalances(completion: { (_) in
                    completion?()
                })
            }
        }
        bitGrail.getBalances { (_) in
            completion?()
        }
        coinExchange.getCurrencyPairs { (_) in
            self.coinExchange.getTickers(completion: { (_) in
                completion?()
            })
        }
        bitfinex.getBalances { (_) in
            completion?()
        }
    }
}
