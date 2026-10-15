// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import Testing

@testable import Application

/// Verifies cancellation releases resources even when no later mutation occurs.
@MainActor
struct ObservationLifetimeTests {
  /// Cancellation releases the callback independently of the observed source.
  @Test(arguments: [false, true])
  func cancellationReleasesCallback(withPendingDelivery: Bool) {
    let source = ObservableValue()
    var owner: ObservableValue? = ObservableValue()
    weak let releasedOwner = owner
    let token = onChange(of: source.value) { [captured = owner] value in
      captured?.value = value
    }
    owner = nil
    #expect(releasedOwner != nil)
    if withPendingDelivery {
      source.value = 1
    }
    token.cancel()
    #expect(releasedOwner == nil)
    token.cancel()
  }

  /// Cancellation also releases the autoclosure's observed source.
  @Test
  func cancellationReleasesValueReader() throws {
    var source: ObservableValue? = ObservableValue()
    weak let releasedSource = source
    let token = observe(try #require(source))
    source = nil
    token.cancel()
    #expect(releasedSource == nil)
  }

  /// Captures the source by value so only the observation keeps it alive.
  private func observe(_ source: ObservableValue) -> ObservationToken {
    onChange(of: source.value) { _ in }
  }
}
