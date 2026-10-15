// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import SwiftUI

/// Demonstrates startup, error recovery, and cross-service observation.
@main
struct TestApplication: App {
  /// Engine retained across reconstruction of the application's scene.
  @State private var engine = TestEngine()

  /// Presents the shared shell with controls for manually completing startup.
  var body: some Scene {
    WindowGroup {
      engine.rootView {
        Text("Running")
        HStack {
          ServiceAView()
          ServiceBView()
        }
        Button("Throw Error Whilst Running", action: engine.fakeErrorRunning)
      } startup: {
        VStack {
          ProgressView()
          Button("Finish Startup", action: engine.fakeFinishedStartup)
          Button("Throw Error In Startup", action: engine.fakeErrorStartup)
        }
      } error: { caughtError, _ in
        Text("Error \(String(describing: caughtError))")
        Button("Resume", action: engine.recoverFromError)
      }
      .task { engine.standardLoop() }
    }
  }
}
