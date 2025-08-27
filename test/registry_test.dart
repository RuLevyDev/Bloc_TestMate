import 'package:bloc_testmate/bloc_testmate.dart';
import 'package:test/test.dart';

void main() {
  test('unregister removes type', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    reg.unregister<int>();
    expect(() => reg<int>(), throwsStateError);
  });

  test('clear removes all', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    reg.register<String>('hi');
    reg.clear();
    expect(() => reg<int>(), throwsStateError);
    expect(() => reg<String>(), throwsStateError);
  });
}
