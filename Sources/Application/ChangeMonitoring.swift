// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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

/// Observes a main-actor value and reruns the handler whenever it changes.
@discardableResult
@MainActor
public func observeChange<Value>(
  of value: @escaping @autoclosure @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) -> ObservationToken {
  onChange(of: value(), perform: perform)
}

public extension NotificationCenter {
  /// Observes notifications on the main queue and returns a token that cancels observation.
  @MainActor
  func onMainActorNotification(
    named name: Notification.Name,
    object: AnyObject? = nil,
    perform: @escaping @MainActor () -> Void
  ) -> NotificationToken {
    let observer = addObserver(forName: name, object: object, queue: nil) { _ in
      // Always enqueue onto the main actor to avoid synchronous re-entrancy when
      // notifications are posted during one-time initialization on the main thread.
      Task { @MainActor in
        perform()
      }
    }

    return NotificationToken(center: self, observer: observer)
  }
}
