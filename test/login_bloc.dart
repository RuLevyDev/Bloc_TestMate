import 'package:bloc/bloc.dart';

abstract class LoginEvent {}

class LoginStarted extends LoginEvent {}

class CredentialsEntered extends LoginEvent {
  final String email;
  final String pass;
  CredentialsEntered(this.email, this.pass);
}

class SubmitPressed extends LoginEvent {}

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

abstract class AuthRepo {
  Future<bool> login(String email, String pass);
}

class FakeAuthRepo implements AuthRepo {
  final bool success;
  FakeAuthRepo({required this.success});
  @override
  Future<bool> login(String email, String pass) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return success && pass == '1234';
  }
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepo _repo;

  String _email = '';
  String _pass = '';

  LoginBloc(this._repo) : super(LoginInitial()) {
    on<LoginStarted>((event, emit) => emit(LoginInitial()));
    on<CredentialsEntered>((event, emit) {
      _email = event.email;
      _pass = event.pass;
    });
    on<SubmitPressed>((event, emit) async {
      emit(LoginLoading());
      final ok = await _repo.login(_email, _pass);
      if (ok) {
        emit(LoginSuccess());
      } else {
        emit(LoginError('Invalid credentials'));
      }
    });
  }
}
