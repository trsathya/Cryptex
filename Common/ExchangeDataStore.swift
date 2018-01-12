//
//  ExchangeDataStore.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 1/6/18.
//

import Foundation

public class ExchangeDataStore<T: TickerType, U: BalanceType> {
    
    public var name = "ExchangeDataStore"
    public var accountingCurrency: Currency = .USD
    public var commonCurrency: Currency = .Bitcoin
    
    public var tickerByQuantityCCY: [[T]] = []
    public var tickerByPriceCCY: [[T]] = []
    public var tickerByName: [T] = []
    
    public var balances: [U] = []
    
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
    
    public func displayablePrice(ticker: T) -> String {
        guard ticker.symbol.price != accountingCurrency else { return "" }
        return ticker.price.stringValue + " " + ticker.symbol.price.code
    }
}

extension ExchangeDataStore: TickerTableViewDataSource {
    
    private func ticker(section: Int, row: Int, viewType: TickerViewType) -> T? {
        switch viewType {
        case .quantity: return tickerByQuantityCCY[section][row]
        case .price: return tickerByPriceCCY[section][row]
        default: return nil
        }
    }
    
    public func sectionCount(viewType: TickerViewType) -> Int {
        switch viewType {
        case .quantity: return tickerByQuantityCCY.count
        case .price: return tickerByPriceCCY.count
        default: return 0
        }
    }
    public func tickerCount(section: Int, viewType: TickerViewType) -> Int {
        switch viewType {
        case .quantity: return tickerByQuantityCCY[section].count
        case .price: return tickerByPriceCCY[section].count
        default: return 0
        }
    }
    public func sectionHeaderTitle(section: Int, viewType: TickerViewType) -> String? {
        switch viewType {
        case .quantity: return tickerByQuantityCCY[section][0].symbol.quantity.name
        case .price: return tickerByPriceCCY[section][0].symbol.price.name
        default: return nil
        }
    }
    public func displayableTicker(section: Int, row: Int, viewType: TickerViewType) -> DisplayableTickerType? {
        guard let t = ticker(section: section, row: row, viewType: viewType) else { return nil }
        let displayable = DisplayableTicker(name: t.symbol.quantity.name, price: displayablePrice(ticker: t), priceInUSD: t.formattedPriceInUSD)
        return displayable
    }
}

extension ExchangeDataStore: BalanceTableViewDataSource {
    
    public func getTotalBalance() -> NSDecimalNumber {
        var totalBalance = NSDecimalNumber.zero
        balances.forEach { totalBalance = totalBalance.adding(balanceInPreferredCurrency(balance: $0)) }
        return totalBalance
    }
    
    public func balanceCount() -> Int {
        return balances.count
    }
    
    public func displayableBalance(row: Int) -> DisplayableBalanceType {
        let balance = balances[row]
        let balanceInPreferredCurrency = self.balanceInPreferredCurrency(balance: balance)
        let price = balanceInPreferredCurrency == balance.quantity ? "" : balance.quantity.stringValue
        let priceInUSD = NumberFormatter.usd.string(from: balanceInPreferredCurrency) ?? ""
        return DisplayableBalance(name: balance.currency.name, balanceQuantity: price, priceInUSD: priceInUSD)
    }
}

