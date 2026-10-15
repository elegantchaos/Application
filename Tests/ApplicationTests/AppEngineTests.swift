// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Application

/// Exercises startup ownership across suspension, recovery, and completion.
@MainActor
@Suite(.timeLimit(.minutes(1)))
struct AppEngineTests {
  /// Repeated advancement and recovery outside an error preserve active work.
  @Test
  func activeStartupIsIdempotent() async throws {
    let engine = StartupTestEngine()
    var starts = engine.starts.makeAsyncIterator()
    engine.standardLoop()
    let task = try #require(engine.startupTask)
    #expect(await starts.next() == 0)
    engine.standardLoop()
    engine.advance()
    engine.recoverFromError()
    #expect(engine.startupTask == task)
    #expect(task.isCancelled == false)
    engine.finish(0)
    await task.value
    #expect(engine.startupTask == nil)
  }

  /// Ordinary startup failures remain recoverable after their task completes.
  @Test
  func completedFailureCanRecover() async throws {
    let engine = StartupTestEngine()
    var starts = engine.starts.makeAsyncIterator()
    engine.standardLoop()
    let task = try #require(engine.startupTask)
    #expect(await starts.next() == 0)
    engine.finish(0, failing: true)
    await task.value
    #expect(engine.startupTask == nil)
    if case .error(_, .starting) = engine.state {
    } else {
      Issue.record("Startup failure did not preserve its interrupted state")
    }

    engine.recoverFromError()
    let replacement = try #require(engine.startupTask)
    #expect(await starts.next() == 1)
    engine.finish(1)
    await replacement.value
    if case .running = engine.state {
    } else {
      Issue.record("Recovery did not finish startup")
    }
  }

  /// A cancelled invocation cannot clear or publish over its replacement.
  @Test(arguments: [false, true])
  func recoveryPreservesReplacement(failing: Bool) async throws {
    let engine = StartupTestEngine()
    var starts = engine.starts.makeAsyncIterator()
    engine.standardLoop()
    let old = try #require(engine.startupTask)
    #expect(await starts.next() == 0)

    engine.caughtError(StartupTestEngine.Failure.startup)
    engine.recoverFromError()
    let replacement = try #require(engine.startupTask)
    #expect(await starts.next() == 1)
    #expect(old.isCancelled)

    engine.finish(0, failing: failing)
    await old.value
    #expect(engine.startupTask == replacement)
    if case .starting = engine.state {
    } else {
      Issue.record("Cancelled startup changed the replacement's state")
    }

    engine.finish(1)
    await replacement.value
    #expect(engine.startupTask == nil)
    if case .running = engine.state {
    } else {
      Issue.record("Replacement did not finish startup")
    }
  }
}
