// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Displays and edits the source service's value.
struct ServiceAView: View {
  /// Shared source service injected by the engine.
  @Environment(ServiceA.self) private var serviceA

  /// Source value and its standard increment control.
  var body: some View {
    VStack {
      Text("A is \(serviceA.value)")
      Button("Change A", action: serviceA.increment)
    }
  }
}

#Preview { ServiceAView().environment(ServiceA()) }
