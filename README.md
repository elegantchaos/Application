# Application

`Application` is a Swift package for shared app-level orchestration and state.

## Contents

- App lifecycle and engine logic
- Shared app state modeling
- Change monitoring helpers

## Lifecycle

An `AppEngine` owns its `AppState` and `startupTask`. Call `standardLoop()` to
initialize and start it. Repeated calls during startup reuse the active work.
`caughtError(_:)` captures the interrupted phase; `recoverFromError()` cancels
pending startup and retries that phase. A cancelled or replaced invocation
cannot publish completion, report an error, or clear its replacement's handle.
Startup implementations must handle cancellation cooperatively to stop their
own work and release resources.

## Change monitoring

`onChange(of:perform:)` tracks a main-actor Observation value and delivers its
latest value on the main actor. Mutations before delivery can coalesce; mutations
inside the callback precede the next tracking pass. Retain the returned
`ObservationToken` when cancellation is needed. Call `cancel()` to stop delivery
and release captured callbacks and value readers immediately. Discarding the
token preserves fire-and-forget observation.

`NotificationCenter.onNotification(named:object:perform:)` and
`UserDefaults.onChange(initial:_:)` return a `NotificationToken`. Retain this token
while monitoring is wanted; cancellation or destruction removes its observer.
The defaults helper can call its handler immediately with `initial: true`.

## Project records

- [Development journal](Extras/Journal/index.md)
- [Decision log](Extras/Decisions/index.md)

