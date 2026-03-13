import SwiftUI

/// Observes a main-actor value and reruns the handler whenever it changes.
///
/// This wraps `withObservationTracking` in a small self-reinstalling loop so the
/// caller gets a callback for each subsequent change rather than only the next
/// one. The returned token owns that loop's lifetime: retain it while
/// observation is desired, and cancel it when the observing object tears down.
///
/// Both the observed value and the callback run on the main actor.
@discardableResult
@MainActor
public func onChange<Value>(
  of value: @escaping @autoclosure @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) -> ObservationToken {
  let token = ObservationToken()
  installObservation(token: token, value: value, perform: perform)
  return token
}

/// Installs a single observation pass and re-registers after each reported change.
@MainActor
private func installObservation<Value>(
  token: ObservationToken,
  value: @escaping @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) {
  withObservationTracking {
    guard !token.cancelled else { return }
    _ = value()
  } onChange: {
    // `onChange` is synchronous, so use a short-lived task only to hop back
    // onto the main actor before touching actor-isolated state and callbacks.
    Task { @MainActor in
      guard !token.cancelled else { return }
      perform(value())
      installObservation(token: token, value: value, perform: perform)
    }
  }
}
