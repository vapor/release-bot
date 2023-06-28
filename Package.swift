// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "release-bot",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor-community/vapor-aws-lambda-runtime", .upToNextMajor(from: "0.4.0")),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "VaporAWSLambdaRuntime", package: "vapor-aws-lambda-runtime"),
        ]),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
