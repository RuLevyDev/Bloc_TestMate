import 'package:bloc_testmate/bloc_testmate.dart';
import '../example/todo_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('GoldenLogger', () {
    test('matches golden file', () async {
      final bloc = TodoBloc(
        FakeTodoRepo(
          seed: const [Todo(id: '1', title: 'seed')],
        ),
      );
      final logger = GoldenLogger<TodoState>(bloc);
      bloc.add(LoadTodos());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      logger.expectMatch('test/goldens/todo_success.json');
      await bloc.close();
    });

    test('throws on mismatch', () async {
      final bloc = TodoBloc(
        FakeTodoRepo(
          seed: const [Todo(id: '1', title: 'seed')],
        ),
      );
      final logger = GoldenLogger<TodoState>(bloc);
      bloc.add(LoadTodos());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(
        () => logger.expectMatch('test/goldens/todo_failure.json'),
        throwsA(isA<TestFailure>()),
      );
      await bloc.close();
    });
  });

  group('scenario golden integration', () {
    final mate = BlocTestMate<TodoBloc, TodoState>()
        .arrange((get) {
          get.register<TodoRepo>(
            FakeTodoRepo(
              seed: const [Todo(id: '1', title: 'seed')],
            ),
          );
        })
        .factory((get) => TodoBloc(get<TodoRepo>()));

    mate.scenario(
      'loads todos matches golden',
      when: (bloc) => bloc.add(LoadTodos()),
      wait: const Duration(milliseconds: 20),
      golden: 'todo_success.json',
    );
  });
}
