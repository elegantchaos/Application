// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/10/2025.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Coordinates initialization, asynchronous startup, recovery, and shell presentation.
///
/// Conforming engines own their state and startup task, and supply modifiers that
/// expose services appropriate to each lifecycle phase. Call `standardLoop()` to
/// start the shell and `recoverFromError()` to retry the interrupted phase.
@MainActor public protocol AppEngine: AnyObject {
  /// Perform one-time, synchronous startup.
  /// This should be as quick as possible, to avoid a delay
  /// before the app shows any UI
  func initialise() throws

  /// Perform asynchronous startup.
  /// Whilst the app is doing this, it will be in the `.starting`
  /// state, and will be showing the startup UI.
  func startup() async throws

  /// Perform any optional retry cleanup
  func retry() async throws

  /// Should an error be ignored?
  /// If this returns false, the error will put the app
  /// into the .error state and show the error ui
  /// If it returns true, the app will continue in the state
  /// it was previously in.
  func shouldIgnore(error: Error) -> Bool

  /// The state that the app is in.
  var state: AppState { get set }

  /// The currently running startup task, if startup is in flight.
  ///
  /// The application loop owns this task explicitly so it can:
  /// - avoid launching duplicate startup work,
  /// - cancel startup during recovery, and
  /// - clear the reference when startup finishes or is cancelled.
  ///
  /// Engines are expected to be long-lived, so this task is treated as
  /// instance-owned lifecycle state rather than detached background work.
  var startupTask: Task<Void, Never>? { get set }

  /// A view modifier which injects environment into a view.
  /// It should assume that the engine isn't fully started yet,
  /// and so (for example) it may not inject services that
  /// could still be starting.
  associatedtype StartupInjector: ViewModifier

  /// Returns a modifier which injects environment.
  var startupInjector: StartupInjector { get }

  /// A view modifier which injects environment into a view.
  /// It can assume that the engine is fully started,
  /// and so (for example) it can force unwrap and inject optional
  /// services that were creating during startup.
  associatedtype RunningInjector: ViewModifier

  /// Returns a modifier which injects environment.
  var runningInjector: RunningInjector { get }

}

@MainActor public extension AppEngine {
  /// Starts the shell; repeated calls while startup is active have no effect.
  func standardLoop() {
    advance()
  }

  /// Advances initialization or installs one owned startup invocation.
  func advance() {
    switch state {
      case .uninitialised:
        do {
          try initialise()
          state = .starting
          advance()
        } catch {
          caughtError(error)
        }
      case .starting:
        guard startupTask == nil else { return }

        // The captured handle identifies this invocation across suspension. Clear
        // the capture on completion to break its reference back to the task.
        var task: Task<Void, Never>?
        task = Task { @MainActor in
          defer {
            if startupTask == task {
              startupTask = nil
            }
            task = nil
          }
          do {
            try await startup()
            guard !Task.isCancelled, startupTask == task else { return }
            state = .running
          } catch is CancellationError {
            // Cancellation is a normal control-flow path here. Recovery can
            // cancel startup intentionally before rewinding state, so there is
            // nothing to report to the error UI.
          } catch {
            guard !Task.isCancelled, startupTask == task else { return }
            caughtError(error)
          }
        }
        startupTask = task
      default:
        break
    }
  }

  /// Presents an error unless the engine explicitly ignores it.
  func caughtError(_ error: Error) {
    if !shouldIgnore(error: error) {
      state = .error(error, state)
    }
  }

  /// Cancels interrupted startup and retries the phase captured by the error.
  func recoverFromError() {
    switch state {
      case .error(_, let previousState):
        startupTask?.cancel()
        startupTask = nil
        state = previousState
        advance()
      default:
        break
    }
  }

  /// Presents the view and service environment appropriate to the current state.
  func rootView<S: View, R: View, E: View>(
    @ViewBuilder running: () -> R,
    @ViewBuilder startup: () -> S = { DefaultStartupView() },
    @ViewBuilder error: (Error, AppState) -> E = { e, s in DefaultErrorView(e, s) }
  ) -> some View {
    Group {
      switch state {
        case .uninitialised, .starting:
          startup()
            .modifier(startupInjector)
        case .running, .terminating:
          running()
            .modifier(runningInjector)
        case .error(let e, let previousState):
          error(e, previousState)
      }
    }
  }
}
