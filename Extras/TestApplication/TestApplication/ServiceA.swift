// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Provides the source value used to demonstrate change monitoring.
@MainActor
@Observable
final class ServiceA {
  /// Value changed by the source view.
  var value = 0

  /// Increments the source value from a user action.
  func increment() { value += 1 }
}
