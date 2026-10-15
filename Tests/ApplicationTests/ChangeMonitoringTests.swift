// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Application

/// Tests callback delivery using explicit signals from the actual handler.
@MainActor
@Suite(.timeLimit(.minutes(1)))
struct ChangeMonitoringTests {
  /// Sequential mutations each deliver their updated value.
  @Test
  func sequentialChangesDeliverCallbacks() async {
    let source = ObservableValue()
    let (values, delivered) = AsyncStream.makeStream(of: Int.self)
    var iterator = values.makeAsyncIterator()
    let token = onChange(of: source.value) { delivered.yield($0) }
    defer { token.cancel() }

    source.value = 1
    #expect(await iterator.next() == 1)
    source.value = 2
    #expect(await iterator.next() == 2)
  }

  /// Same-turn mutations coalesce into delivery of the latest value.
  @Test
  func mutationsCoalesce() async {
    let source = ObservableValue()
    let (values, delivered) = AsyncStream.makeStream(of: Int.self)
    var iterator = values.makeAsyncIterator()
    let token = onChange(of: source.value) { delivered.yield($0) }
    defer { token.cancel() }

    source.value = 1
    source.value = 2
    #expect(await iterator.next() == 2)
  }

  /// Cancelling from a handler prevents reinstallation and later delivery.
  @Test
  func handlerCanCancelObservation() async {
    let source = ObservableValue()
    let (values, delivered) = AsyncStream.makeStream(of: Int.self)
    var iterator = values.makeAsyncIterator()
    var token: ObservationToken?
    token = onChange(of: source.value) { value in
      token?.cancel()
      delivered.yield(value)
      delivered.finish()
    }

    source.value = 1
    #expect(await iterator.next() == 1)
    source.value = 2
    #expect(await iterator.next() == nil)
    #expect(token?.cancelled == true)
  }

  /// Discarding the token preserves the supported fire-and-forget API.
  @Test
  func discardedTokenKeepsObserving() async {
    let source = ObservableValue()
    let (values, delivered) = AsyncStream.makeStream(of: Int.self)
    var iterator = values.makeAsyncIterator()
    var token: ObservationToken? = onChange(of: source.value) { delivered.yield($0) }
    weak let activeToken = token
    token = nil
    defer { activeToken?.cancel() }

    source.value = 1
    #expect(await iterator.next() == 1)
    source.value = 2
    #expect(await iterator.next() == 2)
  }
}
