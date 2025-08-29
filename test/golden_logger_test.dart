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
      await logger.expectMatch('test/goldens/todo_success.json');
      await bloc.close();
    });

    test('stops logging after dispose', () async {
      final bloc = TodoBloc(
        FakeTodoRepo(
          seed: const [Todo(id: '1', title: 'seed')],
        ),
      );
      final logger = GoldenLogger<TodoState>(bloc);
      await logger.dispose();
      bloc.add(LoadTodos());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await logger.expectMatch('test/goldens/todo_initial.json');
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
      await expectLater(
        logger.expectMatch('test/goldens/todo_failure.json'),
        throwsA(isA<TestFailure>()),
      );
      await bloc.close();
    });
    test(
      'cancels subscription without awaiting when golden file is missing',
      () async {
        final bloc = TodoBloc(
          FakeTodoRepo(
            seed: const [Todo(id: '1', title: 'seed')],
          ),
        );
        final logger = GoldenLogger<TodoState>(bloc);
        expect(
          () => logger.expectMatch('test/goldens/does_not_exist.json'),
          throwsA(isA<TestFailure>()),
        );
        bloc.add(LoadTodos());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        logger.expectMatch('test/goldens/todo_initial.json');
        await bloc.close();
      },
    );
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
