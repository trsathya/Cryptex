Pod::Spec.new do |s|
  s.name         = "Cryptex"
  s.version      = "0.0.1"
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
    ss.dependency 'Cryptex/Gemini'
  end
  s.subspec "Common" do |ss|
    ss.source_files  = "Common/**/*.swift"
  end
  s.subspec "Gemini" do |ss|
    ss.source_files  = "Gemini/**/*.swift"
    ss.dependency 'Cryptex/Common'
  end
end
