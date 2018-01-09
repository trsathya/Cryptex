Pod::Spec.new do |s|
  s.name         = "Cryptex"
  s.version      = "0.0.2"
  s.summary      = "Cryptocurrency Exchange API Clients in Swift."
  s.description  = <<-DESC
                   Multiple crypto currency exchange api clients in swift.
                   DESC
  s.homepage     = "https://github.com/trsathya/cryptex"
  s.license      = "MIT"
  s.author       = "Sathyakumar Rajaraman"
  s.source       = { :git => "https://github.com/trsathya/cryptex.git", :tag => "#{s.version}" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
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
  end
  s.subspec "Common" do |ss|
    ss.source_files  = "Common/**/*.swift"
  end
  s.subspec "CoinMarketCap" do |ss|
    ss.source_files  = "CoinMarketCap/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Gemini" do |ss|
    ss.source_files  = "Gemini/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "GDAX" do |ss|
    ss.source_files  = "GDAX/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Poloniex" do |ss|
    ss.source_files  = "Poloniex/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Binance" do |ss|
    ss.source_files  = "Binance/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Koinex" do |ss|
    ss.source_files  = "Koinex/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "Cryptopia" do |ss|
    ss.source_files  = "Cryptopia/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "BitGrail" do |ss|
    ss.source_files  = "BitGrail/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
  s.subspec "CoinExchange" do |ss|
    ss.source_files  = "CoinExchange/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
end
