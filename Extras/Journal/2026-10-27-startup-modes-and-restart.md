# Planned: Alternative Startup and In-Process Restart

Date: 2026-10-27

Bookish needs to run a developer repair (reset or rebuild of its store) before its normal runtime exists, and to restart its runtime after an in-app request, without quitting the process. Its [Decision 0042](https://github.com/elegantchaos/Bookish/blob/main/Extras/Decisions/0042-repair-outside-normal-runtime.md) describes the behaviour, and [Application Implementation](https://github.com/elegantchaos/Bookish/blob/main/Extras/Documentation/Application%20Implementation.md#runtime-replacement-lifecycle-work) records the deferral. A Bookish-only wrapper around the engine was proposed and set aside: both capabilities are generic, and `AppEngine` already owns startup.

## To investigate

- **Alternative startup mode.** A way for an application to choose, before normal startup runs, to run something else first: for example when a modifier key such as Shift is held at launch on macOS, or a launch argument asks for it. The application supplies what the mode does and whether it then continues to normal startup; `Application` supplies the choice point and its place in the lifecycle.
- **Hard restart.** A way to shut the engine down completely and start it again in the same process, leaving no tasks, subscriptions or observers from the old run, and then run startup, or an alternative mode, again.

## Starting points

- `AppEngine` already owns `startupTask` and its phases, and `recoverFromError()` cancels pending startup and reruns a phase. A restart generalises that from one phase to the whole run.
- The ownership rules from [PR #1](2026-10-15-pr-1-fixes.md) apply: a cancelled or replaced invocation must not publish completion, report an error or clear its replacement's handle.

## Questions to settle

- Where the state rebuilt by a restart lives. If the engine object survives, it needs an internal runtime that is discarded and rebuilt whole, including the observable state views receive from the environment. Services swapped one at a time would bring back the rebinding problems a restart is meant to avoid.
- How SwiftUI scenes, commands and settings see the restart: what they show while it runs, and how the environment picks up the new state.
- What shutdown guarantees, and how an application's own services join it, so nothing of the old run stays active.
- How the startup mode is chosen and reported, including on iOS, where there is no modifier key at launch.
