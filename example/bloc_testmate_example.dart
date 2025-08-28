import 'package:bloc_testmate/bloc_testmate.dart';

/// Import your example bloc (you can copy the one in test/login_bloc.dart)
import '../test/login_bloc.dart';

void main() {
  final mate = BlocTestMate<LoginBloc, LoginState>()
      .arrange((get) {
        // Register a fake AuthRepo that returns success
        get.register<AuthRepo>(FakeAuthRepo(success: true));
      })
      .factory((get) => LoginBloc(get<AuthRepo>()));

  // Simple example: login succeeds
  mate.scenario(
    'login ok',
    given: () => [CredentialsEntered('a@a.com', '1234')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginSuccess>()],
  );

  // Simple example: login fails
  mate.scenario(
    'login falla',
    arrange: (get) =>
        get.register<AuthRepo>(FakeAuthRepo(success: false), override: true),
    given: () => [CredentialsEntered('a@a.com', 'bad')],
    when: (bloc) => bloc.add(SubmitPressed()),
    wait: const Duration(milliseconds: 20),
    expectStates: [isA<LoginLoading>(), isA<LoginError>()],
  );
}
