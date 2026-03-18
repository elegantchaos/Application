// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Cancellation token for an installed observation callback.
///
/// The application package uses recursive `withObservationTracking` to
/// re-install change handlers after each observed mutation. Keeping the token
/// separate makes that lifecycle explicit: the owner can retain the token for as
/// long as observation should remain active, then call `cancel()` to stop any
/// future re-registration.
@MainActor
public final class ObservationToken {
  @ObservationIgnored private var isCancelled = false

  /// Creates an active token.
  public init() {
  }

  /// Prevents any future observation callbacks from being installed.
  public func cancel() {
    isCancelled = true
  }

  /// Returns whether the token has been cancelled.
  var cancelled: Bool {
    isCancelled
  }
}
