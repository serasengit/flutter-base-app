# Debugging

This document explains the local Bloc debugging workflow implemented in this repository.

The current setup provides a lightweight custom viewer for `bloc` and `flutter_bloc` state changes during development. It is intended to offer a practical inspection workflow similar in spirit to Redux/ngrx devtools, but adapted to the current Flutter architecture.

## Goal

The viewer exists to make Bloc and Cubit state changes easier to inspect while the app is running.

It captures:

- bloc and cubit creation
- incoming bloc events
- state changes
- bloc transitions
- bloc errors
- bloc close lifecycle
- a global snapshot of known bloc/cubit state at the time each message is emitted

This is a development-only tool.

## High-Level Architecture

The debugging flow has two runtime parts:

1. The Flutter app
2. The local viewer server

The app emits debug messages over WebSocket.

The viewer:

- accepts WebSocket messages from the Flutter app
- stores a bounded in-memory history
- exposes an HTML UI over HTTP
- pushes the received timeline to connected browser tabs

## Relevant Files

Flutter side:

- `lib/main.dart`
- `lib/core/debug/bloc_devtools/bloc_devtools_bootstrap.dart`
- `lib/core/debug/bloc_devtools/bloc_devtools_client.dart`
- `lib/core/debug/bloc_devtools/bloc_devtools_observer.dart`
- `lib/core/debug/bloc_devtools/bloc_devtools_codec.dart`

Viewer side:

- `tool/bloc_devtools_viewer.dart`

Tests:

- `test/core/debug/bloc_devtools_codec_test.dart`
- `test/core/debug/bloc_devtools_observer_test.dart`

## Flutter App Flow

### 1. Bootstrap

The app entry point is `lib/main.dart`.

During startup:

1. Flutter bindings are initialized
2. repository dependencies are registered
3. Bloc devtools bootstrap is executed in debug assertions
4. app config is loaded
5. the app widget tree starts

Current debug bootstrap:

- `initializeBlocDevtools(locator)` from `bloc_devtools_bootstrap.dart`

This bootstrap:

- creates a `BlocDevToolsClient`
- starts its WebSocket connection logic
- assigns a global `Bloc.observer`

### 2. Global Observer

The observer is implemented in `bloc_devtools_observer.dart`.

It listens to:

- `onCreate`
- `onEvent`
- `onChange`
- `onTransition`
- `onError`
- `onClose`

Each hook produces a structured message and sends it through the transport sink.

### 3. Global App State Snapshot

The observer also keeps an in-memory map of known blocs and cubits.

For each instance, it stores:

- bloc runtime type
- serialized current state

This map is attached to every outgoing message as `appState`.

That means when you select an event in the viewer, you can inspect not only the event payload itself, but also the global state snapshot that the observer knew at that moment.

### 4. Serialization

Serialization is handled by `bloc_devtools_codec.dart`.

The codec tries to convert Dart objects into JSON-safe structures.

Supported strategies:

- primitive values are passed through directly
- `DateTime` becomes ISO-8601 text
- `Duration` becomes microseconds
- `Enum` becomes `name`
- `Uri` becomes string
- `Iterable` becomes array
- `Map` becomes object
- `Equatable` becomes:
  - `type`
  - `props`

If direct JSON encoding succeeds, that result is used.

If it does not, the codec falls back to `toString()`.

Important limitation:

`Equatable.props` is positional, not named. That is why many state objects appear as:

```json
{
  "type": "State",
  "props": [
    ...,
    ...
  ]
}
```

instead of:

```json
{
  "prop1": ...,
  "prop2": ...
}
```

### 5. WebSocket Client

The client lives in `bloc_devtools_client.dart`.

Responsibilities:

- connect to the local viewer
- reconnect periodically if disconnected
- send observer messages as JSON strings
- log connection failures in debug

Default URLs:

- Android emulator: `ws://10.0.2.2:58987/events`
- other platforms: `ws://127.0.0.1:58987/events`

The URL can be overridden with:

```bash
--dart-define=BLOC_DEVTOOLS_URL=ws://<host>:58987/events
```

## Viewer Flow

The viewer is implemented as a small Dart server in `tool/bloc_devtools_viewer.dart`.

It exposes:

- `GET /` for the browser UI
- `WS /events` for Flutter app messages
- `WS /viewer` for browser realtime updates

### 1. Event Ingestion

When the Flutter app connects to `/events`:

- the server upgrades the request to a WebSocket
- incoming JSON messages are validated
- messages are normalized with `jsonEncode`
- they are stored in a ring buffer-like history

Current history cap:

- 500 events

When the cap is reached, the oldest event is discarded.

### 2. Browser Synchronization

When the browser opens the page:

- the HTML page connects to `/viewer`
- the server replays current history to that tab
- future messages are pushed live

This allows a browser refresh without losing the current in-memory timeline, as long as the viewer process is still running.

## Viewer UI

The browser UI is a single embedded HTML page served by the Dart process.

### Left Panel

The left panel contains:

- connection status
- search input
- bloc filter
- clear timeline button
- visible event count
- active bloc count
- event timeline

Each timeline item shows:

- message kind
- sequence number
- bloc runtime type
- a hint derived from event/state type

### Right Panel

The detail panel contains:

- selected event title
- selected event kind
- tabs
- detail content

Tabs currently available:

- `Payload`
- `App State`
- `Diff` for `change` and `transition` messages only

### Payload Tab

This tab contains two side-by-side sections:

- `Resumen`
- `Payload`

`Resumen` is a condensed object built by the viewer from the selected message:

- bloc
- kind
- timestamp
- event type
- current state type
- next state type

`Payload` shows the full raw event object received by the viewer.

### App State Tab

This tab shows the `appState` snapshot captured by the observer at message emission time.

It is useful for answering:

- what did the full shell state look like at this moment?
- what did auth state look like when this event arrived?
- what other blocs had already updated?

### Diff Tab

The `Diff` tab is visible only when the selected message contains both:

- `currentState`
- `nextState`

This typically applies to:

- `change`
- `transition`

The diff is currently viewer-side only. It does not require additional protocol changes.

The viewer compares both serialized states recursively and reports differences by path.

Examples:

- `state.props[0]`
- `state.props[1].props[2]`
- `state.someField`

Diff classifications:

- `added`
- `removed`
- `changed`

Current limitation:

If states are serialized through `Equatable.props`, the diff path is positional, not semantic. That means you may see `props[1]` instead of a real field name.

## Collapsible JSON Viewer

The JSON shown in:

- `Resumen`
- `Payload`
- `App State`

is rendered as a collapsible tree.

Objects and arrays are displayed using expandable nodes.

This allows you to:

- collapse `props`
- collapse nested objects
- inspect large payloads without losing context

This is especially useful for deeply nested serialized Equatable states.

## Running the Viewer

Start the viewer:

```bash
dart run tool/bloc_devtools_viewer.dart
```

Open the browser:

```text
http://127.0.0.1:58987
```

Run the Flutter app in debug mode.

Example for Android emulator:

```bash
flutter run --dart-define=BLOC_DEVTOOLS_URL=ws://10.0.2.2:58987/events
```

The VS Code launch config can also pass the same `dart-define`.

## VS Code Launch Configurations

Using `launch.json` is the easiest way to avoid retyping the WebSocket host for each environment.

The `dart-define` you care about is:

```text
BLOC_DEVTOOLS_URL
```

Example `.vscode/launch.json` with multiple targets:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Android Emulator + Bloc Viewer",
      "program": "lib/main.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=BLOC_DEVTOOLS_URL=ws://10.0.2.2:58987/events"]
    },
    {
      "name": "Desktop Local + Bloc Viewer",
      "program": "lib/main.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=BLOC_DEVTOOLS_URL=ws://127.0.0.1:58987/events"]
    },
    {
      "name": "Android Device LAN + Bloc Viewer",
      "program": "lib/main.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=BLOC_DEVTOOLS_URL=ws://192.168.1.40:58987/events"]
    }
  ]
}
```

Use the host that matches the runtime target:

- Android emulator: `10.0.2.2`
- desktop app running on the same machine: `127.0.0.1`
- physical Android device: your host machine LAN IP, for example `192.168.1.40`

Practical notes:

- after changing Android manifest-related debug setup, prefer a full restart over hot reload
- if you change the viewer HTML/JS, restart the viewer process and refresh the browser tab
- if you change only the Flutter observer/client code, restart the app

## Environment Recipes

### Android Emulator

Recommended launch value:

```text
ws://10.0.2.2:58987/events
```

Why:

- `127.0.0.1` inside the emulator is the emulator itself
- `10.0.2.2` is the standard bridge from Android emulator to the host machine

Checklist:

1. start the viewer
2. confirm browser UI is reachable at `http://127.0.0.1:58987`
3. run the app with `BLOC_DEVTOOLS_URL=ws://10.0.2.2:58987/events`
4. confirm Flutter logs show the devtools client connecting

### Flutter Desktop

Recommended launch value:

```text
ws://127.0.0.1:58987/events
```

Why:

- the app and the viewer run on the same host
- no emulator bridge is needed

### Physical Android Device

Recommended launch value:

```text
ws://<your-lan-ip>:58987/events
```

Example:

```text
ws://192.168.1.40:58987/events
```

Requirements:

- phone and development machine on the same network
- Windows firewall allows the Dart viewer process or port
- router/client isolation is not blocking local peers

If it still does not connect:

- verify the phone can reach a page on the host LAN IP
- verify the viewer is bound to a non-loopback address
- check Flutter logs for the WebSocket connection error

## Other Useful Debug Measures

The custom Bloc viewer is helpful, but it should not be the only debugging tool.

Useful complementary measures:

- keep `logger` output enabled for request lifecycle and failures
- inspect `AppBloc` transitions when changing shell navigation behavior
- inspect `AuthBloc` events and transitions when working on session restore/login/logout
- use targeted widget or bloc tests when behavior is deterministic
- use integration tests for navigation flows that depend on module state or async startup
- keep event/state payloads small and readable where possible, especially for debug serialization

### When To Prefer Tests Over The Viewer

Use tests first when:

- you are validating a precise state sequence
- the bug is deterministic
- the issue is tied to one bloc in isolation

Use the viewer first when:

- multiple blocs interact
- shell state and auth state influence each other
- timing or user flow matters
- you need to understand the order of events rather than just the final state

### Recommended Debug Workflow

For state-related issues, this workflow is usually the most efficient:

1. reproduce with the viewer running
2. identify which bloc emitted the unexpected transition
3. inspect `Payload` to confirm the triggering event
4. inspect `App State` to understand the wider application context
5. inspect `Diff` for the exact state mutation
6. convert the finding into a focused unit/widget/integration test

## Debugging Connection Issues

If the viewer UI loads but the app does not connect, verify these in order:

1. the viewer process is actually running on port `58987`
2. the app target is using the correct host in `BLOC_DEVTOOLS_URL`
3. Android debug networking allows cleartext traffic
4. the selected `launch.json` configuration matches the runtime target
5. the viewer logs show requests hitting `/events`
6. the Flutter logs show either a successful connection or the actual socket error

Useful signals:

- browser UI reachable, but no `/events` traffic:
  likely wrong `BLOC_DEVTOOLS_URL`
- `/events` traffic reaches the server, but no upgrade:
  likely path or handshake problem
- app attempts connection but gets refused:
  viewer process not running or blocked by firewall

## Android Notes

For Android development there are three important details:

1. The app must run in debug mode
2. `ws://10.0.2.2:<port>` is normally required from the emulator to reach the host machine
3. debug Android manifest needs cleartext traffic enabled for non-TLS WebSocket traffic

The repository already includes debug manifest setup for that workflow.

## What Each Message Kind Means

### `create`

Sent when a bloc or cubit is created.

Includes:

- bloc type
- initial serialized state
- global app state snapshot

### `event`

Sent when a `Bloc` receives an event.

Includes:

- bloc type
- event payload
- current serialized state
- global app state snapshot at event arrival

### `change`

Sent when a bloc or cubit changes state.

Includes:

- current state
- next state
- global app state snapshot updated to the next state

### `transition`

Sent when a `Bloc` processes an event into a new state.

Includes:

- event
- current state
- next state
- global app state snapshot

Conceptually, a transition is:

```text
event + currentState -> nextState
```

### `error`

Sent when a bloc or cubit reports an error.

Includes:

- error text
- stack trace
- current app state snapshot

### `close`

Sent when a bloc or cubit is closed.

Includes:

- final state
- app state snapshot

After sending the close message, the observer removes the bloc from the internal global snapshot map.

## Current Limitations

### 1. Runtime type identity

The observer currently uses `runtimeType.toString()` as the key for app-state tracking.

That means if two instances of the same bloc type exist simultaneously, one may overwrite the other in `appState`.

Possible future fix:

- use `runtimeType + identity/hashCode`

### 2. No time travel

This tool is not Redux/ngrx time travel.

It does not:

- replay application state
- restore past states
- dispatch old events back into the app

It is an inspection tool, not a state restoration engine.

### 3. No named Equatable fields

Because `Equatable` exposes positional props only, many diffs and payloads are indexed arrays.

Possible future fix:

- use `toJson()` when available

### 4. In-memory only

History is not persisted.

If the viewer process stops, the timeline is lost.

### 5. Local development only

The transport is plain local WebSocket over cleartext and is intended only for development.

## Suggested Future Improvements

The following improvements would add the most value:

- preserve expanded/collapsed JSON node state between event selections
- group related `event`, `transition`, and `change` entries
- export timeline to JSON
- diff rendering with richer side-by-side visualization
- support multiple bloc instances of the same runtime type
- optional timestamps with relative duration between events

## Troubleshooting

### Viewer opens but shows no events

Check:

- the Flutter app is running in debug
- the viewer process is running
- the WebSocket URL matches the current target
- the app logs show a successful client connection

### WebSocket upgrade errors

Common causes:

- wrong path
- wrong host
- cleartext not enabled in Android debug
- old viewer process still running

### App connects but no meaningful payload names appear

That is expected for many `Equatable` objects.

The current serializer can only access positional `props`, not field names.

## Summary

The current Bloc viewer gives the repository:

- global Bloc/Cubit lifecycle visibility
- event and state inspection
- recursive state diffs for changes and transitions
- a point-in-time app-wide state snapshot
- collapsible JSON inspection

It is intentionally simple, local-first, and repository-controlled, which makes it easy to evolve alongside the app architecture.
