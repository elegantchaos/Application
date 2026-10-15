// swift-tools-version: 6.2

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

/// Shared application orchestration and its regression tests.
let package = Package(
  name: "Application",

  platforms: [
    .macOS("26.0"), .iOS("26.0"), .tvOS("26.0"),
  ],

  products: [
    .library(
      name: "Application",
      targets: ["Application"]
    )
  ],

  targets: [
    .target(
      name: "Application"
    ),
    .testTarget(
      name: "ApplicationTests",
      dependencies: ["Application"]
    ),
  ]
)

for target in package.targets {
  switch target.type {
    case .regular:
      var settings = target.swiftSettings ?? []
      settings.append(contentsOf: [
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ])
      target.swiftSettings = settings
    case .test:
      var settings = target.swiftSettings ?? []
      settings.append(contentsOf: [
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ])
      target.swiftSettings = settings
    default:
      continue
  }

}
