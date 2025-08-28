import 'package:test/test.dart' as test;

/// Table-driven testing helpers for `BlocTestMate`.
///
/// A table groups together multiple data [Row]s and runs the same [build]
/// function for each one. This is handy when several scenarios share the same
/// structure but differ only by their inputs.
/// Each [Row] is a `Map<String, Object?>` that supplies data to the `build`
/// callback. Include a descriptive key such as `desc` or `name` so that each
/// case is easy to identify in test output, and use additional keys for the
/// values consumed by the scenario.

/// A single data entry consumed by [table].
///
/// Keys should be short, descriptive names. Including a `desc`/`name` entry is
/// recommended so each test case can be labeled clearly.
typedef Row = Map<String, Object?>;

/// Callback that is run for each [Row] provided to [table].
typedef BuildRow = void Function(Row row);

/// Runs `build(row)` for each entry (useful with `mate.scenario(...)`).
void table(String name, {required List<Row> rows, required BuildRow build}) {
  test.group(name, () {
    for (final row in rows) {
      build(row);
    }
  });
}
