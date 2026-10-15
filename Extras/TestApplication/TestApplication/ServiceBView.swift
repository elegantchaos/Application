// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Displays the mirrored service and permits independent edits.
struct ServiceBView: View {
  /// Shared mirrored service injected by the engine.
  @Environment(ServiceB.self) private var serviceB

  /// Mirrored value and its standard increment control.
  var body: some View {
    VStack {
      Text("B is \(serviceB.value)")
      Button("Change B", action: serviceB.increment)
    }
  }
}

#Preview { ServiceBView().environment(ServiceB(serviceA: ServiceA())) }
