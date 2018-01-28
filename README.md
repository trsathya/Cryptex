# Cryptex

![Swift 4.0](https://img.shields.io/badge/Swift-4.0-brightgreen.svg) ![badge-platforms] ![badge-pms] ![CocoaPods](https://img.shields.io/cocoapods/v/Cryptex.svg) [![GitHub release](https://img.shields.io/github/release/trsathya/Cryptex.svg)](https://github.com/trsathya/Cryptex/releases) ![Cocoapods Downloads](	https://img.shields.io/cocoapods/dt/Cryptex.svg) ![Github Commits Since last release](https://img.shields.io/github/commits-since/trsathya/Cryptex/latest.svg) ![badge-mit]

Cryptex, a single Swift 4 library to access multiple crypto currency exchange APIs.

## Requirements

- iOS 8.0+ | macOS 10.10+ | tvOS 9.0+ | watchOS 2.0+ 
- Xcode 8.3+

## Integration

#### CocoaPods (iOS 8+, OS X 10.9+)

To install all exchanges
```ruby
pod 'Cryptex', '~> 0.0.3'
```

To install only one exchange
```ruby
pod 'Cryptex/Gemini', '~> 0.0.3'
```

To install two or more exchanges
```ruby
pod 'Cryptex', '~> 0.0.3', :subspecs => ['Gemini', 'GDAX', "Poloniex"]
```

#### Carthage (iOS 8+, OS X 10.9+)

```
github "trsathya/Cryptex" ~> 0.0.3
```

#### Swift Package Manager

```swift
dependencies: [
    .Package(url: "https://github.com/trsathya/Cryptex.git", from: "0.0.3"),
]
```

## Usage

#### Initialization

```swift
import Cryptex
```

##### Fetch coinmarketcap.com global data
```swift
let coinMarketCapService = CoinMarketCap.Service(key: nil, secret: nil, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
coinMarketCapService.getGlobal { (_) in
    if let data = coinMarketCapService.store.globalMarketDataResponse.globalData {
        print(data)
    }
}
```

##### Console logs
```
GET https://api.coinmarketcap.com/v1/global
200 https://api.coinmarketcap.com/v1/global/
Response Data: {
    "total_market_cap_usd": 585234214361.0, 
    "total_24h_volume_usd": 22202189284.0, 
    "bitcoin_percentage_of_market_cap": 34.15, 
    "active_currencies": 896, 
    "active_assets": 567, 
    "active_markets": 8187, 
    "last_updated": 1517118863
}
Optional(Cryptex.CoinMarketCap.GlobalMarketData(marketCap: 585234214361, volume24Hrs: 22202189284, bitcoinDominance: 34.15, activeCurrencies: 896, activeAssets: 567, activeMarkets: 8187, lastUpdated: 1517118863))

```
Or

##### Fetch Gemini public ticker data
```swift
let geminiService = Gemini.Service(key: nil, secret: nil, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
geminiService.getTickers { (_) in
    print(geminiService.store.tickerByName)
}
```
##### Console logs
```
GET https://api.gemini.com/v1/symbols
200 https://api.gemini.com/v1/symbols
GET https://api.gemini.com/v1/pubticker/BTCUSD
GET https://api.gemini.com/v1/pubticker/ETHBTC
GET https://api.gemini.com/v1/pubticker/ETHUSD
200 https://api.gemini.com/v1/pubticker/ETHBTC
200 https://api.gemini.com/v1/pubticker/ETHUSD
200 https://api.gemini.com/v1/pubticker/BTCUSD
[
BTCUSD : 11721 USD, 
ETHBTC : 0.0977 BTC, 
ETHUSD : 1148.99 USD]
```
Or
##### Fetch Gemini private account balance data
```swift
let geminiService = Gemini.Service(key: <Your gemini account api key>, secret: <Your gemini account api secret>, session: URLSession.shared, userPreference: .USD_BTC, currencyOverrides: nil)
geminiService.getBalances { (_) in
    for balance in self.gemini.store.balances {
        print("\(balance) \(self.gemini.store.balanceInPreferredCurrency(balance: balance).usdFormatted ?? "")")
    }
}
```
##### Console logs
```
GET https://api.gemini.com/v1/symbols
200 https://api.gemini.com/v1/symbols
GET https://api.gemini.com/v1/pubticker/BTCUSD
GET https://api.gemini.com/v1/pubticker/ETHBTC
GET https://api.gemini.com/v1/pubticker/ETHUSD
200 https://api.gemini.com/v1/pubticker/BTCUSD
200 https://api.gemini.com/v1/pubticker/ETHUSD
200 https://api.gemini.com/v1/pubticker/ETHBTC
POST https://api.gemini.com/v1/balances
200 https://api.gemini.com/v1/balances

BTC: 0.29182653 $3,420.49
USD: 26.96 $26.96
ETH: 0.00000017 $0.00

```

[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-green.svg
[badge-platforms]: https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-lightgrey.svg
[badge-mit]: https://img.shields.io/badge/license-MIT-blue.svg
