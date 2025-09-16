## 1.0.0

- Initial release of Bloc_TestMate with a scenario‑oriented helper for BLoC testing, enabling fake registration, defining scenarios with expected states, and comparing results with golden files
- Includes TestRegistry, a minimal dependency registry for registering instances or lazy factories and resetting state between scenarios
- Adds GoldenLogger to serialize and compare BLoC states against JSON golden files, cancelling subscriptions after verification
- Provides stream comparison utilities such as emitsInOrderStates, emitsWhere, and noMoreStates to validate emitted state sequences
- Introduces table‑driven testing support via table(...), executing a scenario with multiple data rows

## 1.0.1

- Flutter dev dependencie added.
- keywords added.
- CI ready.

## 1.0.2

- Add CLI generator: scan BLoCs and generate placeholder tests via `dart run bloc_testmate testmate --config bloc_testmate.yaml`.
- Improve Windows support for include/exclude globs in the scanner (use POSIX-style matching and handle root-level files).
- Add API docs for `BlocTestMate` library, `Arrange`, `BlocTestMate()` constructor, and the `arrange` and `factory` methods.

## 1.0.3
- dart format fix

## 1.0.4
- dart format.

## 1.0.5
- analyzer upgraded , bin impl removed
## 1.0.6
- Expanded dependency ranges
## 1.0.7
- Relaxed the analyzer constraint to stay compatible with Flutter's pinned `test_api` dependency.