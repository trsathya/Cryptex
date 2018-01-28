//
//  Currency.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/30/17.
//  Copyright © 2017 Sathyakumar. All rights reserved.
//

import Foundation

public class Currency: Hashable, Comparable {
    public let name: String
    public let code: String
    
    public init(name: String, code: String) {
        self.name = name
        self.code = code.uppercased()
    }

    public var hashValue: Int {
        return code.hashValue
    }
    
    public static func <(lhs: Currency, rhs: Currency) -> Bool {
        if lhs.name == rhs.name {
            return lhs.code < rhs.code
        } else {
            return lhs.name < rhs.name
        }
    }
    
    public static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code.lowercased() == rhs.code.lowercased()
    }
}

public extension Currency {
    
    public convenience init(code: String) {
        self.init(name: code, code: code)
    }
    
    static let USD = Currency(name: "United States dollar", code: "USD")
    static let EUR = Currency(name: "Euro", code: "EUR")
    static let JPY = Currency(name: "Japanese yen", code: "JPY")
    static let GBP = Currency(name: "Pound sterling", code: "GBP")
    static let AUD = Currency(name: "Australian dollar", code: "AUD")
    static let CAD = Currency(name: "Canadian dollar", code: "CAD")
    static let CHF = Currency(name: "Swiss franc", code: "CHF")
    static let CNY = Currency(name: "Renminbi", code: "CNY")
    static let SEK = Currency(name: "Swedish krona", code: "SEK")
    static let NZD = Currency(name: "New Zealand dollar", code: "NZD")
    static let MXN = Currency(name: "Mexican peso", code: "MXN")
    static let SGD = Currency(name: "Singapore dollar", code: "SGD")
    static let HKD = Currency(name: "Hong Kong dollar", code: "HKD")
    static let NOK = Currency(name: "Norwegian krone", code: "NOK")
    static let KRW = Currency(name: "South Korean won", code: "KRW")
    static let TRY = Currency(name: "Turkish lira", code: "TRY")
    static let RUB = Currency(name: "Russian ruble", code: "RUB")
    static let INR = Currency(name: "Indian rupee", code: "INR")
    static let BRL = Currency(name: "Brazilian real", code: "BRL")
    static let ZAR = Currency(name: "South African rand", code: "ZAR")
    
    static let Bitcoin = Currency(name: "Bitcoin", code: "BTC")
    static let Ethereum = Currency(name: "Ethereum", code: "ETH")
    static let Litecoin = Currency(name: "Litecoin", code: "LTC")
    static let Ripple = Currency(name: "Ripple", code: "XRP")
    static let Cardano = Currency(name: "Cardano", code: "ADA")
    static let NEM = Currency(name: "NEM", code: "XEM")
    static let USDT = Currency(name: "Tether USD", code: "USDT")
    
    static let bitcoinCash =    Currency(name: "Bitcoin Cash", code: "BCH")
    static let bitcoinGold =    Currency(name: "Bitcoin Gold", code: "BTG")
    static let zcash =          Currency(name: "ZCash", code: "ZEC")
    static let ethereumClassic = Currency(name: "Ethereum Classic", code: "ETC")
    static let stellar =        Currency(name: "Stellar", code: "STR")
    static let dash =           Currency(name: "Dash", code: "DASH")
    static let nxt =            Currency(name: "NXT", code: "NXT")
    static let monero =         Currency(name: "Monero", code: "XMR")
    static let augur =          Currency(name: "Augur", code: "REP")
    
    static let bytecoin =       Currency(name: "Bytecoin", code: "BCN")
    static let bitcoinDark =    Currency(name: "BitcoinDark", code: "BTCD")
    static let mainSafeCoin =   Currency(name: "MainSafeCoin", code: "MAID")
    static let blackCoin =      Currency(name: "BlackCoin", code: "BLK")
    
    static let golem =          Currency(name: "Golem", code: "GNT")
    static let lisk =           Currency(name: "Lisk", code: "LSK")
    static let gnosis =         Currency(name: "Gnosis", code: "GNO")
    static let steem =          Currency(name: "STEEM", code: "STEEM")
    
    static let siacoin =        Currency(name: "Siacoin", code: "SC")
    static let digiByte =       Currency(name: "DigiByte", code: "DGB")
    static let bitShares =      Currency(name: "BitShares", code: "BTS")
    static let stratis =        Currency(name: "Stratis", code: "STRAT")
    static let factom =         Currency(name: "Factom", code: "FCT")
    static let syscoin =        Currency(name: "Syscoin", code: "SYS")
    static let dogecoin =       Currency(name: "Dogecoin", code: "DOGE")
    static let gameCredits =    Currency(name: "GameCredits", code: "GAME")
    static let lbryCredits =    Currency(name: "LBRY Credits", code: "LBC")
    static let decred =         Currency(name: "Decred", code: "DCR")
    static let neoscoin =       Currency(name: "Neoscoin", code: "NEOS")
    static let viacoin =        Currency(name: "Viacoin", code: "VIA")
    static let omni =           Currency(name: "Omni", code: "OMNI")
    static let synereoAMP =     Currency(name: "Synereo AMP", code: "AMP")
    static let vertcoin =       Currency(name: "Vertcoin", code: "VTC")
    static let counterparty =   Currency(name: "Counterparty", code: "XCP")
    static let clams =          Currency(name: "CLAMS", code: "CLAM")
    static let pascalCoin =     Currency(name: "PascalCoin", code: "PASC")
    static let gridcoinResearch = Currency(name: "GridCoin Research", code: "GRC")
    static let storjcoinX =     Currency(name: "Storjcoin X", code: "SJCX")
    static let potCoin =        Currency(name: "PotCoin", code: "POT")
    static let burst =          Currency(name: "Burst", code: "BURST")
    static let huntercoin =     Currency(name: "Huntercoin", code: "HUC")
    static let bitmark =        Currency(name: "Bitmark", code: "BTM")
    static let bitCrystals =    Currency(name: "BitCrystals", code: "BCY")
    static let primecoin =      Currency(name: "Primecoin", code: "XPM")
    static let belacoin =       Currency(name: "Belacoin", code: "BELA")
    static let peercoin =       Currency(name: "Peercoin", code: "PPC")
    static let einsteinium =    Currency(name: "Einsteinium", code: "EMC2")
    static let expanse =        Currency(name: "Expanse", code: "EXP")
    
    static let dnotes =         Currency(name: "DNotes", code: "NOTE")
    static let radium =         Currency(name: "Radium", code: "RADS")
    static let veriCoin =       Currency(name: "VeriCoin", code: "VRC")
    static let navCoin =        Currency(name: "NAVCoin", code: "NAV")
    static let florincoin =     Currency(name: "Florincoin", code: "FLO")
    static let pinkcoin =       Currency(name: "Pinkcoin", code: "PINK")
    static let namecoin =       Currency(name: "Namecoin", code: "NMC")
    static let nautiluscoin =   Currency(name: "Nautiluscoin", code: "NAUT")
    static let foldingCoin =    Currency(name: "FoldingCoin", code: "FLDC")
    static let nexium =         Currency(name: "Nexium", code: "NXC")
    static let vcash =          Currency(name: "Vcash", code: "XVC")
    static let riecoin =        Currency(name: "Riecoin", code: "RIC")
    static let bitcoinPlus =    Currency(name: "BitcoinPlus", code: "XBC")
    static let steemDollars =   Currency(name: "Steem Dollars", code: "SBD")
    
    static let digixDAO =   Currency(name: "DigixDAO", code: "DGD")
    static let neo =   Currency(name: "Neo", code: "NEO")
    static let zCoin =   Currency(name: "ZCoin", code: "XZC")
    static let qtum =   Currency(name: "Qtum", code: "QTUM")
    static let gas =   Currency(name: "Gas", code: "GAS")
    static let populous =   Currency(name: "Populous", code: "PPT")
    static let binanceCoin =   Currency(name: "Binance Coin", code: "BNB")
    static let bitcoinDiamond =   Currency(name: "Bitcoin Diamond", code: "BCD")
    
    private static let currencies: [Currency] = [
        USD, EUR, JPY, GBP, AUD, CAD, CHF, CNY, SEK, NZD, MXN, SGD, HKD, NOK, KRW, TRY, RUB, INR, BRL, ZAR,
        Bitcoin,
        Ethereum,
        Ripple,
        Litecoin,
        Cardano,
        NEM,
        USDT,
        
        ]
    
    static var currencyLookupDictionary: [String: Currency] = {
        return dictionary(array: Currency.currencies)
    }()
    
    static func dictionary(array: [Currency]) -> [String: Currency] {
        var dictionary: [String: Currency] = [:]
        array.forEach({ (currency) in
            dictionary[currency.code] = currency
        })
        return dictionary
    }
}
