
# bloc_testmate

[![pub package](https://img.shields.io/pub/v/bloc_testmate.svg)](https://pub.dev/packages/bloc_testmate)
[![likes](https://img.shields.io/pub/likes/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)
[![pub points](https://img.shields.io/pub/points/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)
[![popularity](https://img.shields.io/pub/popularity/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)

> Write BLoC tests in **1–2 lines** with clear, scenario-driven syntax.  
> Pattern: `arrange → act → assert`.

## Overview
**bloc_testmate** is a Dart/Flutter package that streamlines testing for BLoCs.  
It wraps `bloc_test` with a tiny test-oriented DI container and a scenario API so you can focus on behavior, not boilerplate. It also supports data-driven tests, helpful matchers, and async-friendly waits.

### Why?
- Less setup noise, more **intent**.
- Inline fakes/mocks per scenario.
- Easy to scale with **tables** for combinations.
- Readable failures (state sequences are easy to compare).

---

## Features
- **Minimal DI** for tests: `get.register<T>(fake)` and `get<T>()`.
- **Scenarios** in one call: `mate.scenario('...', ...)`.
- **Data-driven** tests: `table('name', rows: [...], build: ...)`.
- **Matchers** ready to use: `isA`, `predicate` (re-exported from `package:test`).
- **Async support**: optional `wait:` to accommodate delayed repos, timers, etc.
- Works with **`bloc`**, **`bloc_test`**, **`test`**, **`mocktail`**.

---

## Installation
Add to `pubspec.yaml`:
```yaml
dependencies:
  bloc_testmate: ^1.0.0
````

Or:

```bash
flutter pub add bloc_testmate
```

Then:

```bash
dart pub get
```

---

## Quick Start

### 1) Create a test mate

```dart
final mate = BlocTestMate<LoginBloc, LoginState>()
  .arrange((get) {
    // Register per-suite defaults (can be overridden per-scenario)
    get.register<AuthRepo>(FakeAuthRepo(success: true));
  })
  .factory((get) => LoginBloc(get<AuthRepo>()));
```

### 2) Write a scenario (success)

```dart
mate.scenario(
  'login success',
  given: () => [CredentialsEntered('a@a.com', '1234')],
  when: (bloc) => bloc.add(SubmitPressed()),
  wait: const Duration(milliseconds: 20), // if your repo is async
  expectStates: [
    isA<LoginLoading>(),
    isA<LoginSuccess>(),
  ],
);
```

### 3) Override dependencies per scenario (failure)

```dart
mate.scenario(
  'login failure',
  arrange: (get) => get.register<AuthRepo>(FakeAuthRepo(success: false)),
  given: () => [CredentialsEntered('a@a.com', 'bad')],
  when: (bloc) => bloc.add(SubmitPressed()),
  wait: const Duration(milliseconds: 20),
  expectStates: [
    isA<LoginLoading>(),
    isA<LoginError>(),
  ],
);
```

### 4) Data-driven table

```dart
table(
  'login combinations',
  rows: const [
    {'ok': true,  'email': 'a@a.com', 'pass': '1234'},
    {'ok': false, 'email': 'a@a.com', 'pass': 'bad'},
  ],
  build: (row) {
    mate.scenario(
      'ok=${row['ok']}',
      arrange: (get) =>
          get.register<AuthRepo>(FakeAuthRepo(success: row['ok'] == true)),
      given: () => [CredentialsEntered(row['email']!, row['pass']!)],
      when: (bloc) => bloc.add(SubmitPressed()),
      wait: const Duration(milliseconds: 20),
      expectStates: (row['ok'] == true)
          ? [isA<LoginLoading>(), isA<LoginSuccess>()]
          : [isA<LoginLoading>(), isA<LoginError>()],
    );
  },
);
```

---

## Example (CRUD)

Check the **`example/`** folder for a complete **Todo CRUD** BLoC:

* `todo_bloc.dart` – domain, fake repo, and `TodoBloc`
* `bloc_testmate_crud_example.dart` – scenarios for load/create/update/delete + error and table

Run the example tests:

```bash
dart test example/
```

---

## API (MVP)

### `BlocTestMate<B extends Bloc<Object?, S>, S>`

* `arrange(Arrange a)` – register defaults for all scenarios (fakes/mocks).
* `factory(B Function(TestRegistry get) f)` – build the BLoC using the registry.
* `scenario(...)` – define a test scenario.
* `group(...)` – optional grouping (re-exports `test.group`).

### `table(...)`

Run multiple scenarios from a row set (great for combinations).

---

## Tips & Gotchas

* If your fake repo uses `Future.delayed`, set `wait:` in `scenario` to allow async completion.
* If you dispatch an event that emits an **initial state**, either expect it explicitly or skip that event in `given:`.
* Override defaults per scenario with `arrange:`.

---

## Roadmap

* Golden state transition logs (JSON + diff).
* Fake clock helpers for debounce/throttle.
* Generator for test skeletons based on your events/states.

---

## License

MIT – see [LICENSE](LICENSE).

