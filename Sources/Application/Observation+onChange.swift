// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation

/// Observes a main-actor value and delivers its latest value after a mutation.
///
/// Delivery hops to the main actor; mutations before delivery can coalesce into
/// one callback. Mutations performed by the handler precede the next tracking
/// pass and do not trigger an additional callback.
///
/// Call `cancel()` on the returned token to stop delivery and release captured
/// resources. Discarding the token leaves observation active. Both the value
/// reader and callback run on the main actor.
@discardableResult
@MainActor
public func onChange<Value>(
  of value: @escaping @autoclosure @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) -> ObservationToken {
  let token = ObservationToken()
  token.install {
    [weak token] in
    guard let token else { return }
    withObservationTracking {
      _ = value()
    } onChange: {
      // Only the token is retained by Observation. Cancellation can therefore
      // release the value reader and callback before another mutation arrives.
      Task { @MainActor in
        token.didChange()
      }
    }
  } handler: {
    perform(value())
  }
  return token
}
