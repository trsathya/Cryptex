# Cryptex

![Swift 4.0](https://img.shields.io/badge/Swift-4.0-brightgreen.svg) ![badge-platforms] ![badge-pms] ![CocoaPods](https://img.shields.io/cocoapods/v/Cryptex.svg) [![GitHub release](https://img.shields.io/github/release/trsathya/Cryptex.svg)](https://github.com/trsathya/Cryptex/releases) ![Cocoapods Downloads](	https://img.shields.io/cocoapods/dt/Cryptex.svg) ![Github Commits Since last release](https://img.shields.io/github/commits-since/trsathya/Cryptex/latest.svg) ![badge-mit]

Cryptex, a single Swift 4 library to access multiple crypto currency exchange APIs.

## Requirements

- iOS 8.0+ | macOS 10.10+ | tvOS 9.0+ | watchOS 2.0+ 
- Xcode 8.3+
- Swift 3.1+

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
    .Package(url: "https://github.com/trsathya/Cryptex.git", from: "0, 0, 3"),
]
```

[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-green.svg
[badge-platforms]: https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-lightgrey.svg
[badge-mit]: https://img.shields.io/badge/license-MIT-blue.svg
