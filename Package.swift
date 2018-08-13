// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "NIOSlackIncomingWebhooks",
    products: [
        .library(name: "NIOSlackIncomingWebhooks", targets: ["NIOSlackIncomingWebhooks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/http", from: "3.0.0"),
    ],
    targets: [
        .target(name: "NIOSlackIncomingWebhooks", dependencies: ["HTTP"]),
        .testTarget(name: "NIOSlackIncomingWebhooksTests", dependencies: ["NIOSlackIncomingWebhooks"]),
    ]
)
