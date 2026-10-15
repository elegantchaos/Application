// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

@testable import Application

/// Suspends each startup invocation until a test explicitly completes it.
@MainActor
final class StartupTestEngine: AppEngine {
  /// State presented by the shared application shell.
  var state: AppState = .uninitialised

  /// Startup work owned by the shell.
  var startupTask: Task<Void, Never>?

  /// Signals that an invocation has installed its completion continuation.
  let starts: AsyncStream<Int>

  /// Publishes startup readiness without relying on executor timing.
  private let started: AsyncStream<Int>.Continuation

  /// Pending invocations, indexed by their startup order.
  private var pending: [CheckedContinuation<Void, any Error>] = []

  /// Creates a fresh shell with buffered readiness signals.
  init() {
    (starts, started) = AsyncStream.makeStream(of: Int.self)
  }

  /// Leaves synchronous initialization empty for lifecycle tests.
  func initialise() throws {}

  /// Waits for the test to finish this startup invocation.
  func startup() async throws {
    try await withCheckedThrowingContinuation { continuation in
      pending.append(continuation)
      started.yield(pending.count - 1)
    }
  }

  /// Requires no retry cleanup for this fixture.
  func retry() async throws {}

  /// Surfaces test errors through the shared shell.
  func shouldIgnore(error: any Error) -> Bool { false }

  /// Supplies an identity modifier while startup is pending.
  var startupInjector: EmptyModifier { EmptyModifier() }

  /// Supplies an identity modifier after startup completes.
  var runningInjector: EmptyModifier { EmptyModifier() }

  /// Completes exactly one invocation with the requested result.
  func finish(_ index: Int, failing: Bool = false) {
    if failing {
      pending[index].resume(throwing: Failure.startup)
    } else {
      pending[index].resume()
    }
  }

  /// Errors used to put the shell into recovery and fail pending startup.
  enum Failure: Error {
    /// A startup failure that should be displayed unless its task was cancelled.
    case startup
  }
}
