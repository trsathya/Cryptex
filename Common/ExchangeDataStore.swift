//
//  ExchangeDataStore.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/6/18.
//

import Foundation

public class ExchangeDataStore<T: TickerType, U: BalanceType> {
    
    public var name = "ExchangeDataStore"
    public var accountingCurrency = Currency.USD
    public var commonCurrency = Currency.Bitcoin
    
    public var tickersDictionary: [String: T] = [:] {
        didSet {
            let tickers = tickersDictionary.values.flatMap{$0}
            var byQuantityCCY: [Currency: [T]] = [:]
            var byPriceCCY: [Currency: [T]] = [:]
            Set(tickers.map { $0.symbol.quantity }).forEach { byQuantityCCY[$0] = [] }
            Set(tickers.map { $0.symbol.price }).forEach { byPriceCCY[$0] = [] }
            tickers.forEach { ticker in
                byQuantityCCY[ticker.symbol.quantity]?.append(ticker)
                byPriceCCY[ticker.symbol.price]?.append(ticker)
            }
            tickerByQuantityCCY = byQuantityCCY.values.sorted(by: { (leftArray, rightArray) -> Bool in
                guard let left = leftArray.first, let right = rightArray.first else { return false }
                return left.priceInUSD.compare(right.priceInUSD) == .orderedDescending
            })
            tickerByPriceCCY = byPriceCCY.keys.flatMap { byPriceCCY[$0] }
            tickerByName = tickers.sorted(by: { (left, right) -> Bool in
                return left.symbol.displaySymbol < right.symbol.displaySymbol
            })
        }
    }
    public var tickerByQuantityCCY: [[T]] = []
    public var tickerByPriceCCY: [[T]] = []
    public var tickerByName: [T] = []
    
    public var balances: [U] = []
    
    private func setPriceInUSD(tickers: [T]) -> [T] {
        return tickers.map({ (ticker) -> T in
            if ticker.symbol.price == accountingCurrency {
                var t = ticker
                t.priceInUSD = ticker.price
                return t
            } else if let usdPrice = tickers.filter({
                return $0.symbol == CurrencyPair(quantity: ticker.symbol.price, price: accountingCurrency) }).first?.price
            {
                var t = ticker
                t.priceInUSD = usdPrice.multiplying(by: ticker.price)
                return t
            }
            return ticker
        })
    }
    
    public func setTicker(ticker: T, symbol: String) {
        var temp = tickersDictionary
        temp[symbol] = ticker
        setTickersInDictionary(tickers: setPriceInUSD(tickers: temp.values.flatMap{$0}))
    }
    
    public func setTickersInDictionary(tickers: [T]) {
        tickersDictionary = [:]
        var dictionary: [String: T] = [:]
        setPriceInUSD(tickers: tickers).forEach { dictionary[$0.symbol.displaySymbol] = $0 }
        tickersDictionary = dictionary
    }
    
    public func tickers(viewType: TickerViewType) -> [[T]] {
        switch viewType {
        case .quantity: return tickerByQuantityCCY
        case .price: return tickerByPriceCCY
        default: return [tickerByName]
        }
    }
    
    public func titleForHeader(viewType: TickerViewType, section: Int) -> String {
        let currencyPair = tickers(viewType: viewType)[section][0].symbol
        switch viewType {
        case .quantity: return currencyPair.quantity.name
        case .price: return currencyPair.price.name
        default: return ""
        }
    }
    
    public func balanceInPreferredCurrency(balance: BalanceType) -> NSDecimalNumber {
        
        let fiatCurrencyPair = CurrencyPair(quantity: balance.currency, price: accountingCurrency)
        let cryptoCurrencyPair = CurrencyPair(quantity: balance.currency, price: commonCurrency)
        if let ticker = (tickerByName.filter {$0.symbol == fiatCurrencyPair}).first {
            return balance.quantity.multiplying(by: ticker.priceInUSD)
        } else if let ticker = (tickerByName.filter {$0.symbol == cryptoCurrencyPair}).first {
            return balance.quantity.multiplying(by: ticker.priceInUSD)
        } else {
            return balance.quantity
        }
    }
    
    public func getTotalBalance() -> NSDecimalNumber {
        var totalBalance = NSDecimalNumber.zero
        balances.forEach { totalBalance = totalBalance.adding(balanceInPreferredCurrency(balance: $0)) }
        return totalBalance
    }
}
