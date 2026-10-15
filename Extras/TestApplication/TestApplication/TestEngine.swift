// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Foundation
import SwiftUI

/// Owns the demo services and suspends startup until a user completes or fails it.
///
/// Services available immediately are injected into startup views. Successful
/// startup creates the remaining service before the shell presents running views.
@MainActor
@Observable
final class TestEngine: AppEngine {
  /// Current shell phase.
  var state: AppState = .uninitialised

  /// Asynchronous startup owned by the shared shell.
  @ObservationIgnored var startupTask: Task<Void, Never>?

  /// Service available during every shell phase.
  private let constantService = ConstantService()

  /// Service created by successful asynchronous startup.
  private var slowService: SlowStartupService?

  /// Source for the observation demonstration.
  private let serviceA: ServiceA

  /// Service mirroring source mutations.
  private let serviceB: ServiceB

  /// Pending startup completion, identified so late cancellation cannot affect a retry.
  @ObservationIgnored private var startupContinuation: (id: UUID, continuation: CheckedContinuation<Void, any Error>)?

  /// Creates the source service and its dependent mirror.
  init() {
    let source = ServiceA()
    serviceA = source
    serviceB = ServiceB(serviceA: source)
  }

  /// No synchronous initialization is needed by the demo.
  func initialise() throws {}

  /// Waits for a user action, bridging task cancellation to the pending continuation.
  func startup() async throws {
    let id = UUID()
    try await withTaskCancellationHandler {
      try Task.checkCancellation()
      try await withCheckedThrowingContinuation { continuation in
        startupContinuation = (id, continuation)
      }
    } onCancel: {
      Task { @MainActor [weak self] in
        self?.cancelStartup(id: id)
      }
    }
  }

  /// Requires no additional retry cleanup.
  func retry() async throws {}

  /// Displays every requested demo error.
  func shouldIgnore(error: any Error) -> Bool { false }

  /// Injects the service available while startup is pending.
  var startupInjector: some ViewModifier { StartupEnvironment(engine: self) }

  /// Injects all services available after startup succeeds.
  var runningInjector: some ViewModifier { RunningEnvironment(engine: self) }

  /// Completes a pending startup once and creates its remaining service.
  func fakeFinishedStartup() {
    guard let pending = startupContinuation else { return }
    startupContinuation = nil
    slowService = SlowStartupService()
    pending.continuation.resume()
  }

  /// Fails a pending startup once so the shell can offer recovery.
  func fakeErrorStartup() {
    guard let pending = startupContinuation else { return }
    startupContinuation = nil
    pending.continuation.resume(throwing: TestError.fakeStartupError)
  }

  /// Presents a recoverable error from the running phase.
  func fakeErrorRunning() { caughtError(TestError.fakeRunningError) }

  /// Resumes only the continuation belonging to the cancelled invocation.
  private func cancelStartup(id: UUID) {
    guard let pending = startupContinuation, pending.id == id else { return }
    startupContinuation = nil
    pending.continuation.resume(throwing: CancellationError())
  }

  /// Exposes services that can be used before startup completes.
  private struct StartupEnvironment: ViewModifier {
    /// Engine providing the early service.
    let engine: TestEngine

    /// Adds the early service to the content's environment.
    func body(content: Content) -> some View {
      content.environment(engine.constantService)
    }
  }

  /// Exposes the services required by the running demo.
  private struct RunningEnvironment: ViewModifier {
    /// Engine providing the fully initialized services.
    let engine: TestEngine

    /// Adds running services, including the optional startup-created service.
    func body(content: Content) -> some View {
      content
        .environment(engine.constantService)
        .environment(engine.slowService)
        .environment(engine.serviceA)
        .environment(engine.serviceB)
    }
  }
}
