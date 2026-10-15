// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Owns the value reader and callback for an installed observation loop.
///
/// Call `cancel()` to stop delivery and immediately release captured resources.
/// Installed observation keeps the token alive, so discarding the returned token
/// leaves monitoring active. Retain it when explicit cancellation is needed.
@MainActor
public final class ObservationToken {
  /// Whether this token has permanently stopped monitoring.
  private var isCancelled = false

  /// Installs the next tracking pass without retaining this token itself.
  private var observation: (@MainActor @Sendable () -> Void)?

  /// Reads the current value and delivers it to the caller.
  private var handler: (@MainActor @Sendable () -> Void)?

  /// Creates an active token without an installed observation.
  public init() {}

  /// Stops future callbacks and releases the value reader and handler immediately.
  public func cancel() {
    isCancelled = true
    observation = nil
    handler = nil
  }

  /// Returns whether the token has been cancelled.
  var cancelled: Bool { isCancelled }

  /// Takes ownership of the callbacks and installs the first tracking pass.
  func install(
    observation: @escaping @MainActor @Sendable () -> Void,
    handler: @escaping @MainActor @Sendable () -> Void
  ) {
    guard !isCancelled else { return }
    self.observation = observation
    self.handler = handler
    observation()
  }

  /// Delivers a mutation and tracks the next change unless the handler cancelled.
  func didChange() {
    handler?()
    observation?()
  }
}
