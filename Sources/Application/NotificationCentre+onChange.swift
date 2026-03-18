// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension NotificationCenter {
  /// Observes notifications on the main queue and returns a token that cancels observation.
  @MainActor
  func onNotification(
    named name: Notification.Name,
    object: AnyObject? = nil,
    perform: @escaping @MainActor () -> Void
  ) -> NotificationToken {
    let observer = addObserver(forName: name, object: object, queue: .main) { _ in
      MainActor.assumeIsolated { perform() }
    }
    
    return NotificationToken(center: self, observer: observer)
  }
}
