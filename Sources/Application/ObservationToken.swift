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

/// Cancellation token for an installed notification callback.
///
/// This owns a Foundation notification observer so notification-based change
/// monitoring can use the same explicit lifetime management as Observation.
@MainActor
public final class NotificationToken {
  nonisolated(unsafe) private var center: NotificationCenter?
  nonisolated(unsafe) private var observer: NSObjectProtocol?

  /// Creates an active token for the supplied notification observer.
  public init(center: NotificationCenter, observer: NSObjectProtocol) {
    self.center = center
    self.observer = observer
  }

  /// Prevents any future notification callbacks from being delivered.
  public func cancel() {
    if let observer {
      center?.removeObserver(observer)
      self.observer = nil
      center = nil
    }
  }

  deinit {
    if let observer {
      center?.removeObserver(observer)
    }
  }
}
