// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Cancellation token for an installed notification callback.
///
/// This owns a Foundation notification observer so notification-based change
/// monitoring can use the same explicit lifetime management as Observation.
@MainActor
public final class NotificationToken {
  /// Notification center responsible for the installed observer.
  private var center: NotificationCenter?

  /// Foundation observer removed by explicit cancellation or destruction.
  private var observer: NSObjectProtocol?

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

  /// Removes any remaining observer on the same actor used by cancellation.
  isolated deinit {
    if let observer {
      center?.removeObserver(observer)
    }
  }
}
