// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "server",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "server",
            targets: ["server"]),
    ],
    dependencies: [
        .package(name: "PerfectHTTPServer", url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
		.package(name: "PerfectWebSockets", url:"https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.0.0"),
		.package(path: "../shared"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "server",
            dependencies: ["PerfectHTTPServer", "PerfectWebSockets", "shared"]),
        .testTarget(
            name: "serverTests",
            dependencies: ["server"]),
    ]
)
