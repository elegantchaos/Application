import Observation
import Testing

@testable import Application

/// Tests the cancellable observation helpers used by Application clients.
struct ChangeMonitoringTests {
  /// Simple observable value source for observation tests.
  @MainActor
  @Observable
  final class ObservableValue {
    var value = 0
  }

  /// Verifies that each sequential change produces one callback.
  @Test
  @MainActor
  func onChangeDeliversOneCallbackPerSequentialChange() async {
    let source = ObservableValue()
    var observedValues: [Int] = []

    let token = onChange(of: source.value) { value in
      observedValues.append(value)
    }

    await confirmation("first callback") { first in
      source.value = 1
      await Task.yield()
      #expect(observedValues == [1])
      first.confirm()
    }

    await confirmation("second callback") { second in
      source.value = 2
      await Task.yield()
      #expect(observedValues == [1, 2])
      second.confirm()
    }

    token.cancel()
  }

  /// Verifies that cancelling the token stops later callbacks.
  @Test
  @MainActor
  func observationTokenCancelStopsFutureCallbacks() async {
    let source = ObservableValue()
    var observedValues: [Int] = []

    let token = onChange(of: source.value) { value in
      observedValues.append(value)
    }

    source.value = 1
    await Task.yield()
    #expect(observedValues == [1])

    token.cancel()
    source.value = 2
    await Task.yield()

    #expect(observedValues == [1])
  }
}
