import 'package:bloc_testmate/bloc_testmate.dart';
import 'package:bloc_testmate/login_bloc.dart';
import 'package:bloc_testmate/todo_bloc.dart';
import 'package:test/test.dart';

void main() {
  final todoMate = BlocTestMate<TodoBloc, TodoState>()
      .arrange((get) {
        get.register<TodoRepo>(
          FakeTodoRepo(
            seed: const [Todo(id: '1', title: 'seed')],
          ),
        );
      })
      .factory((get) => TodoBloc(get<TodoRepo>()));

  // ---------- READ ----------

  todoMate.scenario(
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

  todoMate.scenario(
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

  todoMate.scenario(
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

  todoMate.scenario(
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

  todoMate.scenario(
    'load todos error',
    arrange: (get) =>
        get.register<TodoRepo>(FakeTodoRepo(shouldFail: true), override: true),
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
      todoMate.scenario(
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

  // ---------- LOGIN ----------
  final loginMate = BlocTestMate<LoginBloc, LoginState>()
      .arrange((get) => get.register<AuthRepo>(FakeAuthRepo(success: true)))
      .factory((get) => LoginBloc(get<AuthRepo>()));

  loginMate.scenario(
    'login success',
    given: () => [CredentialsEntered('a@a.com', '1234')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginSuccess>()],
  );

  loginMate.scenario(
    'login failure',
    arrange: (get) =>
        get.register<AuthRepo>(FakeAuthRepo(success: false), override: true),
    given: () => [CredentialsEntered('a@a.com', 'bad')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginError>()],
  );
  // ---------- HOOKS & ERRORS ----------
  var globalSetupCalled = false;
  var globalTearDownCalled = false;

  final hooksMate = BlocTestMate<TodoBloc, TodoState>()
      .setUp(() => globalSetupCalled = true)
      .tearDown(() => globalTearDownCalled = true)
      .arrange((get) => get.register<TodoRepo>(FakeTodoRepo()))
      .factory((get) => TodoBloc(get<TodoRepo>()));

  hooksMate.scenario(
    'supports hooks, initial state and errors',
    setUp: () => expect(globalSetupCalled, isTrue),
    when: (bloc) async {
      bloc.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
    },
    expectInitialState: isA<TodoInitial>(),
    errors: [isA<StateError>()],
    tearDown: () => expect(globalTearDownCalled, isTrue),
  );
}
