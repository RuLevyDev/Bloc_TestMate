import 'dart:io';

import 'package:bloc_testmate/src/cli/bloc_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('scan finds bloc classes', () async {
    final dir = await Directory.systemTemp.createTemp('bloc_scanner_test');
    final blocFile = File('${dir.path}/my_bloc.dart')
      ..writeAsStringSync('''
import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

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

    final blocs = scan(dir.path);
    expect(blocs, hasLength(1));
    expect(blocs.first.name, 'MyBloc');
    expect(p.normalize(blocs.first.path), p.normalize(blocFile.path));
  });
}
