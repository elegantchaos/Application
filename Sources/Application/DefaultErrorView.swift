// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Displays a shell error using its textual description.
public struct DefaultErrorView: View {
  /// Error supplied by the application engine.
  private let error: Error

  /// Creates the standard error presentation for an interrupted shell phase.
  public init(_ error: Error, _ previousState: AppState) {
    self.error = error
  }

  /// Localizable error label containing the diagnostic description.
  public var body: some View {
    Text("Error: \(String(describing: error))")
  }
}

#Preview { DefaultErrorView(CocoaError(.fileReadUnknown), .starting) }
