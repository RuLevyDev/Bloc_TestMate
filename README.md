# BlocTestMate

[![pub package](https://img.shields.io/pub/v/bloc_testmate.svg)](https://pub.dev/packages/bloc_testmate)
[![likes](https://img.shields.io/pub/likes/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)
[![downloads](https://img.shields.io/pub/dt/bloc_testmate.svg)](https://pub.dev/packages/bloc_testmate/score)
[![pub points](https://img.shields.io/pub/points/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)


Scenario-oriented testing utilities for BLoC.

## Package Overview

`BlocTestMate` is a Dart package that helps you write expressive, scenario-based tests for your BLoC classes. Built on top of [`bloc`](https://pub.dev/packages/bloc) and [`bloc_test`](https://pub.dev/packages/bloc_test), it lets you arrange dependencies, define actions, and assert on emitted states with minimal boilerplate. The package includes a lightweight registry for mocks, hooks for setup/teardown and helpers for data-driven testing.

## Features
- Define BLoC test scenarios in 1–2 lines with `scenario`.
- Lightweight dependency registry to register and override fakes per test.
- Global and per-scenario hooks for `setUp` and `tearDown`.
- Data-driven tests with the `table` helper.
- Convenience re-exports for common matchers.
- Golden-state testing via `golden` files.

## Why BlocTestMate instead of `flutter_bloc`?
`flutter_bloc` is the standard solution for implementing the BLoC pattern in Flutter applications. However, it does not provide specialised tools for writing concise scenario tests. `BlocTestMate` focuses purely on testing:

- Reduces boilerplate compared to manually using `bloc_test` with `flutter_bloc`.
- Uses a registry so that mocks and fakes do not leak between scenarios.
- Supports data-driven and parameterised tests out of the box.

Use `flutter_bloc` to build your app and `BlocTestMate` to test it thoroughly.

## Installation
Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_testmate: ^1.0.0
```

or run:

```bash
flutter pub add bloc_testmate
```

Then install the dependencies:

```bash
dart pub get
flutter pub get
```

## Usage

### 1. Define a simple scenario
```dart
import 'package:bloc_testmate/bloc_testmate.dart';

void main() {
  final mate = BlocTestMate<LoginBloc, LoginState>()
      .arrange((get) {
        get.register<AuthRepo>(FakeAuthRepo(success: true));
      })
      .factory((get) => LoginBloc(get<AuthRepo>()));

  mate.scenario(
    'login ok',
    given: () => [CredentialsEntered('a@a.com', '1234')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginSuccess>()],
  );
}
```

### 2. Data-driven testing with `table`
```dart
table(
  'create combinations',
  rows: const [
    {'id': '10', 'title': 'A'},
    {'id': '11', 'title': 'B'},
  ],
  build: (row) {
    mate.scenario(
      'create id=${row['id']}',
      when: (bloc) =>
          bloc.add(CreateTodo(row['id'] as String, row['title'] as String)),
      wait: const Duration(milliseconds: 20),
      expectStates: [
        isA<TodoLoading>(),
        predicate<TodoState>(
          (s) => s is TodoLoaded &&
              s.items.any(
                (t) => t.id == row['id'] && t.title == row['title'],
              ),
        ),
      ],
    );
  },
);
```
### 3. Golden testing
`BlocTestMate` can persist state sequences to JSON "golden" files so that
future runs can verify behaviour hasn't changed.

Pass a `golden` filename to `mate.scenario` to automatically log the states
and compare them against a file stored under `test/goldens/`:

```dart
mate.scenario(
  'loads todos matches golden',
  when: (bloc) => bloc.add(LoadTodos()),
  wait: const Duration(milliseconds: 20),
  golden: 'todo_success.json',
);
```

You can also use `GoldenLogger` directly for fine-grained control:

```dart
final bloc = TodoBloc(FakeTodoRepo());
final logger = GoldenLogger<TodoState>(bloc);

bloc.add(LoadTodos());
await Future<void>.delayed(const Duration(milliseconds: 20));

logger.expectMatch('test/goldens/todo_success.json');
await bloc.close();
```

If you don't call `expectMatch`, make sure to dispose the logger when it's no
longer needed:

```dart
final logger = GoldenLogger<TodoState>(bloc);

// ...

await logger.dispose();
```


## Custom matchers

`BlocTestMate` ships with matchers that make stream expectations concise.

### `emitsInOrderStates`
Verifies that a stream emits the provided states in order and then completes.

```dart
final stream = Stream.fromIterable([1, 2]);
await expectLater(stream, emitsInOrderStates([1, 2, noMoreStates()]));
```

### `emitsWhere`
Matches the next emitted state against a custom predicate.

```dart
final stream = Stream.value(42);
await expectLater(stream, emitsWhere((s) => s == 42));
```

### `noMoreStates`
Asserts that a stream emits no further values and closes.

```dart
final stream = Stream<int>.empty();
await expectLater(stream, noMoreStates());
```

## Parameters
- `arrange`: Override or add fakes for a scenario.
- `given`: Events dispatched before the action.
- `when`: Action executed on the bloc.
- `expectStates`: Expected states or matchers.
- `expectInitialState`: Matcher for the initial state.
- `errors`: Expected errors.
- `setUp` / `tearDown`: Hooks executed before/after each scenario.
- `wait`: Delay before assertions.

## License
This package is open source under the MIT license. See [LICENSE](LICENSE) for details.
