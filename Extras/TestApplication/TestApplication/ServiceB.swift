// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import SwiftUI

/// Mirrors ServiceA mutations while allowing independent edits from its view.
@MainActor
@Observable
final class ServiceB {
  /// Current mirrored or locally edited value.
  var value = 0

  /// Source whose lifetime covers this service's observation.
  private let serviceA: ServiceA

  /// Token retained for explicit teardown of the observation's value reader.
  @ObservationIgnored private var observation: ObservationToken?

  /// Installs a change handler that does not retain this service.
  init(serviceA: ServiceA) {
    self.serviceA = serviceA
    observation = onChange(of: serviceA.value) { [weak self] newValue in
      self?.value = newValue
    }
  }

  /// Releases the value reader when this service is destroyed.
  isolated deinit { observation?.cancel() }

  /// Increments the local value from a user action.
  func increment() { value += 1 }
}
