// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
