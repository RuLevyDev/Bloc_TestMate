import 'package:bloc_testmate/bloc_testmate.dart';

import 'todo_bloc.dart';

void main() {
  // Repo con un item inicial
  final mate = BlocTestMate<TodoBloc, TodoState>()
      .arrange((get) {
        get.register<TodoRepo>(
          FakeTodoRepo(
            seed: const [Todo(id: '1', title: 'seed')],
          ),
        );
      })
      .factory((get) => TodoBloc(get<TodoRepo>()));

  // ---------- READ ----------
  mate.scenario(
    'load todos ok',
    when: (bloc) => bloc.add(LoadTodos()),
    wait: const Duration(milliseconds: 20),
    expectStates: [
      isA<TodoLoading>(),
      predicate<TodoState>(
        (s) =>
            s is TodoLoaded &&
            s.items.length == 1 &&
            s.items.first.title == 'seed',
      ),
    ],
  );

  // ---------- CREATE ----------
  mate.scenario(
    'create todo ok',
    when: (bloc) => bloc.add(CreateTodo('2', 'write tests')),
    wait: const Duration(milliseconds: 20),
    expectStates: [
      isA<TodoLoading>(),
      predicate<TodoState>(
        (s) =>
            s is TodoLoaded &&
            s.items.any((t) => t.id == '2' && t.title == 'write tests'),
      ),
    ],
  );

  // ---------- UPDATE ----------
  mate.scenario(
    'update todo ok',
    when: (bloc) => bloc.add(UpdateTodo('1', 'seed (edited)', true)),
    wait: const Duration(milliseconds: 20),
    expectStates: [
      isA<TodoLoading>(),
      predicate<TodoState>(
        (s) =>
            s is TodoLoaded &&
            s.items.any(
              (t) => t.id == '1' && t.title == 'seed (edited)' && t.done,
            ),
      ),
    ],
  );

  // ---------- DELETE ----------
  mate.scenario(
    'delete todo ok',
    when: (bloc) => bloc.add(DeleteTodo('1')),
    wait: const Duration(milliseconds: 20),
    expectStates: [
      isA<TodoLoading>(),
      predicate<TodoState>(
        (s) => s is TodoLoaded && s.items.every((t) => t.id != '1'),
      ),
    ],
  );

  // ---------- ERROR PATH ----------
  mate.scenario(
    'load todos error',
    arrange: (get) => get.register<TodoRepo>(FakeTodoRepo(shouldFail: true)),
    when: (bloc) => bloc.add(LoadTodos()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<TodoLoading>(), isA<TodoError>()],
  );

  // ---------- DATA-DRIVEN (CREATE) ----------
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
            (s) =>
                s is TodoLoaded &&
                s.items.any(
                  (t) => t.id == row['id'] && t.title == row['title'],
                ),
          ),
        ],
      );
    },
  );
}
