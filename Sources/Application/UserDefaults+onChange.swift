// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension UserDefaults {
  /// Calls the supplied action whenever defaults change.
  @MainActor
  func onChange(initial: Bool = false, _ action: @escaping @MainActor (UserDefaults) -> Void) -> NotificationToken
  {
    if initial {
      action(self)
    }
        
    return NotificationCenter.default.onNotification(
      named: UserDefaults.didChangeNotification,
      object: self
    ) {
      action(self)
    }
  }
}
