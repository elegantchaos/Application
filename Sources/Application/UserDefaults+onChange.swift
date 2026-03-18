// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension UserDefaults {
  /// Calls the supplied action whenever defaults change.
  @MainActor
  func onChanged(_ action: @escaping @MainActor () -> Void) -> NotificationToken
  {
    NotificationCenter.default.onMainActorNotification(
      named: UserDefaults.didChangeNotification,
      object: self
    ) {
      action()
    }
  }
}
