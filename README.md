# BlocTestMate 🧪

[![pub package](https://img.shields.io/pub/v/bloc_testmate.svg)](https://pub.dev/packages/bloc_testmate)
[![likes](https://img.shields.io/pub/likes/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)
[![pub points](https://img.shields.io/pub/points/bloc_testmate?logo=dart)](https://pub.dev/packages/bloc_testmate/score)


Scenario-oriented testing utilities for BLoC 🎯.

## Package Overview 🧭

`BlocTestMate` is a Dart package that helps you write expressive, scenario-based tests for your BLoC classes. Built on top of [`bloc`](https://pub.dev/packages/bloc) and [`bloc_test`](https://pub.dev/packages/bloc_test), it lets you arrange dependencies, define actions, and assert on emitted states with minimal boilerplate. The package includes a lightweight registry for mocks, hooks for setup/teardown and helpers for data-driven testing.

## Features ✨
- Define BLoC test scenarios in 1–2 lines with `scenario`.
- Lightweight dependency registry to register and override fakes per test.
- Global and per-scenario hooks for `setUp` and `tearDown`.
- Data-driven tests with the `table` helper.
- Convenience re-exports for common matchers.
- Golden-state testing via `golden` files.
 - CLI: Generate placeholder tests for discovered `Bloc<_, _>` classes.

## Why BlocTestMate instead of `bloc_test`?
BlocTestMate builds on `bloc_test`, but adds utilities that reduce manual work when writing BLoC tests:

- Scenario DSL lets you define a test case in one or two lines and orchestrate dependencies and actions with minimal code.
- Lightweight registry isolates mocks and fakes between scenarios, with global or per-scenario hooks for `setUp` and `tearDown`.
- Native support for parameterized tests with `table` and for golden-state testing of state sequences.

Using `bloc_test` alone requires assembling all this infrastructure yourself (dependency registry, parameterization, golden-state handling), which leads to more boilerplate and a risk of leaking mocks. BlocTestMate automates these tasks, making complex scenario testing easier.

## Installation 📦
Add the package as a dev dependency to your `pubspec.yaml`:

```yaml
dev_dependencies:
  bloc_testmate: ^1.0.0
```

or run:

```bash
flutter pub add bloc_testmate --dev
```

Then install the dependencies:

```bash
dart pub get
flutter pub get
```

## Usage 🚀

### Running tests ▶️

Run the test suite to verify that your BLoC scenarios behave as expected.

```bash
dart test
```

If your project uses Flutter, run:

```bash
flutter test
```

These tests check state transitions, golden snapshots, and guard against regressions in your BLoCs.

### 1. Define a simple scenario 📝
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

###  🚀CLI: Generate placeholder tests 🛠️

BlocTestMate includes a small CLI that scans your project for `Bloc<_, _>`
classes and generates starter test files.

1. Create a `bloc_testmate.yaml` at the project root:

```yaml
include:
  - lib/**
exclude:
  - lib/generated/**
output: test
```

2. Run the generator:

```bash
dart run bloc_testmate generate --config bloc_testmate.yaml
```

This creates placeholder tests under the configured `output` directory (by
default `test/`). Each file includes a success and error scenario using
`BlocTestMate`.

#### Running without a config file ℹ️
If you omit `--config` or the file does not exist, the CLI uses sensible
defaults:

- include: all Dart files under the current directory
- exclude: none
- output: `test`

Example:

```bash
dart run bloc_testmate generate
```

With these defaults, the CLI scans the current project for classes extending
`Bloc<_, _>` and generates starter tests into `test/`.

### 2. Data-driven testing with `table` 📊
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
### 3. Golden testing 📸
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

await logger.expectMatch('test/goldens/todo_success.json');
await bloc.close();
```

If you don't call `expectMatch`, make sure to dispose the logger when it's no
longer needed:

```dart
final logger = GoldenLogger<TodoState>(bloc);

// ...

await logger.dispose();
```


## Custom matchers 🧩

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

## Parameters ⚙️
- `arrange`: Override or add fakes for a scenario.
- `given`: Events dispatched before the action.
- `when`: Action executed on the bloc.
- `expectStates`: Expected states or matchers.
- `expectInitialState`: Matcher for the initial state.
- `errors`: Expected errors.
- `golden`: JSON file used to compare emitted state sequences.
- `setUp` / `tearDown`: Hooks executed before/after each scenario.
- `wait`: Delay before assertions.

## Windows-friendly globbing 🪟
The CLI uses POSIX-style glob matching internally and normalizes file paths so
that patterns like `**/*.dart` and `**/ignore_bloc.dart` also match files at
the repository root on Windows.

## License 📑
This package is open source under the MIT license. See [LICENSE](LICENSE) for details.
