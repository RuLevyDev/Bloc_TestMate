## 1.0.0


-Initial release of Bloc_TestMate with a scenario‑oriented helper for BLoC testing, enabling fake registration, defining scenarios with expected states, and comparing results with golden files

-Includes TestRegistry, a minimal dependency registry for registering instances or lazy factories and resetting state between scenarios

-Adds GoldenLogger to serialize and compare BLoC states against JSON golden files, cancelling subscriptions after verification

-Provides stream comparison utilities such as emitsInOrderStates, emitsWhere, and noMoreStates to validate emitted state sequences

-Introduces table‑driven testing support via table(...), executing a scenario with multiple data rows
