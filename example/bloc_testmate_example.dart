import 'package:bloc_testmate/bloc_testmate.dart';

/// Importa tu bloc de ejemplo (puedes copiar el que está en test/login_bloc.dart)
import '../test/login_bloc.dart';

void main() {
  final mate = BlocTestMate<LoginBloc, LoginState>()
      .arrange((get) {
        // Registramos un fake AuthRepo que devuelve éxito
        get.register<AuthRepo>(FakeAuthRepo(success: true));
      })
      .factory((get) => LoginBloc(get<AuthRepo>()));

  // Ejemplo simple: login correcto
  mate.scenario(
    'login ok',
    given: () => [CredentialsEntered('a@a.com', '1234')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginSuccess>()],
  );

  // Ejemplo simple: login incorrecto
  mate.scenario(
    'login falla',
    arrange: (get) => get.register<AuthRepo>(FakeAuthRepo(success: false)),
    given: () => [CredentialsEntered('a@a.com', 'bad')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginError>()],
  );
}
