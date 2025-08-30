import 'dart:io';

import 'package:bloc_testmate/src/cli/bloc_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('scan respects include and exclude patterns', () async {
    final dir = await Directory.systemTemp.createTemp('bloc_scanner_test');
    addTearDown(() => dir.deleteSync(recursive: true));

    final blocFile = File('${dir.path}/my_bloc.dart')
      ..writeAsStringSync('''
import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) async* {}
}
''');

    File('${dir.path}/ignore_bloc.dart').writeAsStringSync('''
import 'package:bloc/bloc.dart';

class IgnoreBloc extends Bloc<int, int> {
  IgnoreBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) async* {}
}
''');

    File('${dir.path}/my_cubit.dart').writeAsStringSync('''
import 'package:bloc/bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);
}
''');

    final blocs = scan(
      dir.path,
      include: ['**/*bloc.dart'],
      exclude: ['**/ignore_bloc.dart'],
    );
    expect(blocs, hasLength(1));
    expect(blocs.first.name, 'MyBloc');
    expect(p.normalize(blocs.first.path), p.normalize(blocFile.path));
  });
}
