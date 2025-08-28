import 'package:bloc/bloc.dart';

/// ---------- Dominio ----------
class Todo {
  final String id;
  final String title;
  final bool done;
  const Todo({required this.id, required this.title, this.done = false});

  Todo copyWith({String? id, String? title, bool? done}) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    done: done ?? this.done,
  );
}

/// ---------- Repo ----------
abstract class TodoRepo {
  Future<List<Todo>> fetchAll();
  Future<List<Todo>> create(Todo todo);
  Future<List<Todo>> update(Todo todo);
  Future<List<Todo>> delete(String id);
}

class FakeTodoRepo implements TodoRepo {
  final bool shouldFail;
  final List<Todo> _store;

  FakeTodoRepo({this.shouldFail = false, List<Todo>? seed})
    : _store = [...?seed];

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 10));

  Never _throw() => throw StateError('repo-failure');

  @override
  Future<List<Todo>> fetchAll() async {
    await _latency();
    if (shouldFail) _throw();
    return List.unmodifiable(_store);
  }

  @override
  Future<List<Todo>> create(Todo todo) async {
    await _latency();
    if (shouldFail) _throw();
    _store.add(todo);
    return List.unmodifiable(_store);
  }

  @override
  Future<List<Todo>> update(Todo todo) async {
    await _latency();
    if (shouldFail) _throw();
    final i = _store.indexWhere((t) => t.id == todo.id);
    if (i >= 0) {
      _store[i] = todo;
    }
    return List.unmodifiable(_store);
  }

  @override
  Future<List<Todo>> delete(String id) async {
    await _latency();
    if (shouldFail) _throw();
    _store.removeWhere((t) => t.id == id);
    return List.unmodifiable(_store);
  }
}

/// ---------- Events ----------
abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class CreateTodo extends TodoEvent {
  final String id;
  final String title;
  CreateTodo(this.id, this.title);
}

class UpdateTodo extends TodoEvent {
  final String id;
  final String title;
  final bool done;
  UpdateTodo(this.id, this.title, this.done);
}

class DeleteTodo extends TodoEvent {
  final String id;
  DeleteTodo(this.id);
}

/// ---------- States ----------
abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> items;
  TodoLoaded(this.items);
}

class TodoError extends TodoState {
  final Object error;
  TodoError(this.error);
}

/// ---------- BLoC ----------
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepo _repo;

  TodoBloc(this._repo) : super(TodoInitial()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoLoading());
      try {
        final items = await _repo.fetchAll();
        emit(TodoLoaded(items));
      } catch (e) {
        emit(TodoError(e));
      }
    });

    on<CreateTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        final items = await _repo.create(
          Todo(id: event.id, title: event.title),
        );
        emit(TodoLoaded(items));
      } catch (e) {
        emit(TodoError(e));
      }
    });

    on<UpdateTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        final items = await _repo.update(
          Todo(id: event.id, title: event.title, done: event.done),
        );
        emit(TodoLoaded(items));
      } catch (e) {
        emit(TodoError(e));
      }
    });

    on<DeleteTodo>((event, emit) async {
      emit(TodoLoading());
      try {
        final items = await _repo.delete(event.id);
        emit(TodoLoaded(items));
      } catch (e) {
        emit(TodoError(e));
      }
    });
  }
}
