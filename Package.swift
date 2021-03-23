// swift-tools-version:5.2
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
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            "App",
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
