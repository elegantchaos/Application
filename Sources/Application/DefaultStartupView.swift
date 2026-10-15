// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Displays an indeterminate progress indicator while the engine starts.
public struct DefaultStartupView: View {
  /// Creates the standard startup presentation.
  public init() {}

  /// The system progress indicator for pending startup.
  public var body: some View { ProgressView() }
}

#Preview { DefaultStartupView() }
