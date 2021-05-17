// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cryptex",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Cryptex",
            targets: ["Cryptex"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Cryptex",
            dependencies: ["CryptoSwift"], path: ".", exclude: ["Tests", "CryptexTests"]),
        .testTarget(
            name: "CryptexTests",
            dependencies: ["Cryptex"]),
    ],
    swiftLanguageVersions: [4]
)
