Pod::Spec.new do |s|
  s.name         = "Cryptex"
  s.version      = "0.0.6"
  s.summary      = "Cryptocurrency Exchange API Clients in Swift."
  s.description  = <<-DESC
                   Multiple crypto currency exchange api clients in swift.
                   DESC
  s.homepage     = "https://github.com/trsathya/cryptex"
  s.license      = "MIT"
  s.authors      = 'Sathyakumar Rajaraman', 'Mathias Klenk', 'Rob Saunders'
  s.source       = { :git => "https://github.com/trsathya/cryptex.git", :tag => "#{s.version}" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.requires_arc = true
  s.dependency "CryptoSwift"
  s.default_subspec = "All"
  s.subspec "All" do |ss|
    ss.dependency 'Cryptex/CoinMarketCap'
    ss.dependency 'Cryptex/Gemini'
    ss.dependency 'Cryptex/GDAX'
    ss.dependency 'Cryptex/Poloniex'
    ss.dependency 'Cryptex/Binance'
    ss.dependency 'Cryptex/Koinex'
    ss.dependency 'Cryptex/Cryptopia'
    ss.dependency 'Cryptex/BitGrail'
    ss.dependency 'Cryptex/CoinExchange'
    ss.dependency 'Cryptex/Bitfinex'
    ss.dependency 'Cryptex/Kraken'
  end
  s.subspec "Common" do |ss|
    ss.source_files  = "Sources/Common/**/*.swift"
  end
  s.subspec "CoinMarketCap" do |ss|
    ss.source_files  = "Sources/CoinMarketCap.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Gemini" do |ss|
    ss.source_files  = "Sources/Gemini.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "GDAX" do |ss|
    ss.source_files  = "Sources/GDAX.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Poloniex" do |ss|
    ss.source_files  = "Sources/Poloniex.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Binance" do |ss|
    ss.source_files  = "Sources/Binance.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Koinex" do |ss|
    ss.source_files  = "Sources/Koinex.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Cryptopia" do |ss|
    ss.source_files  = "Sources/Cryptopia.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "BitGrail" do |ss|
    ss.source_files  = "Sources/BitGrail.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "CoinExchange" do |ss|
    ss.source_files  = "Sources/CoinExchange.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Bitfinex" do |ss|
    ss.source_files  = "Sources/Bitfinex.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Kraken" do |ss|
    ss.source_files  = "Sources/Kraken.swift"
    ss.dependency 'Cryptex/Common'
  end
end
