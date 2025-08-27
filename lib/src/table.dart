import 'package:test/test.dart' as test;

typedef Row = Map<String, Object?>;
typedef BuildRow = void Function(Row row);

/// Ejecuta `build(row)` por cada fila (útil con `mate.scenario(...)`).
void table(String name, {required List<Row> rows, required BuildRow build}) {
  test.group(name, () {
    for (final row in rows) {
      build(row);
    }
  });
}
